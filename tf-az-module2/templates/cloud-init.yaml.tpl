#cloud-config
package_update: true
package_upgrade: false

write_files:
  - path: /etc/blobfuse2/config.yaml
    permissions: '0600'
    owner: root:root
    content: |
      allow-other: true
      logging:
        type: syslog
        level: log_warning
      components:
        - libfuse
        - file_cache
        - attr_cache
        - azstorage
      libfuse:
        attribute-expiration-sec: 240
        entry-expiration-sec: 240
        negative-entry-expiration-sec: 120
      file_cache:
        path: /tmp/blobfuse-cache
        timeout-sec: 120
        max-size-mb: 4096
      attr_cache:
        timeout-sec: 7200
      azstorage:
        type: block
        account-name: ${storage_account_name}
        account-key: ${storage_account_key}
        endpoint: https://${storage_account_name}.blob.core.windows.net/
        mode: key
        container: ${container_name}

  - path: /etc/systemd/system/blobfuse.service
    permissions: '0644'
    content: |
      [Unit]
      Description=Blobfuse2 mount of ${container_name}
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=forking
      ExecStartPre=/bin/mkdir -p /mnt/blobfuse
      ExecStartPre=/bin/mkdir -p /tmp/blobfuse-cache
      ExecStart=/usr/bin/blobfuse2 mount /mnt/blobfuse --config-file=/etc/blobfuse2/config.yaml -o allow_other
      ExecStop=/usr/bin/fusermount3 -u /mnt/blobfuse
      Restart=on-failure
      RestartSec=10

      [Install]
      WantedBy=multi-user.target

  - path: /etc/nginx/sites-available/default
    permissions: '0644'
    content: |
      server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /mnt/blobfuse;
        index index.html;
        server_name _;

        location / {
          try_files $uri $uri/ =404;
        }
      }

runcmd:
  - wget -O /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
  - dpkg -i /tmp/packages-microsoft-prod.deb
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confold" -o Dpkg::Options::="--force-confdef" blobfuse2 fuse3 nginx
  - mkdir -p /mnt/blobfuse /tmp/blobfuse-cache
  - systemctl daemon-reload
  - systemctl enable --now blobfuse.service
  - sleep 10
  - systemctl restart nginx

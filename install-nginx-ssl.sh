#!/bin/bash

# 安装 Nginx
echo "🟢 安装 Nginx 中..."
sudo apt update && sudo apt install nginx -y

# 让用户输入证书路径
echo "请输入 SSL 证书路径（例如 /root/cert/fullchain.cer）:"
read cert_path
echo "请输入 SSL 私钥路径（例如 /root/cert/mac.pioz.cn.key）:"
read key_path

# 验证证书文件存在
if [[ ! -f "$cert_path" ]]; then
  echo "❌ 证书文件不存在：$cert_path"
  exit 1
fi

if [[ ! -f "$key_path" ]]; then
  echo "❌ 私钥文件不存在：$key_path"
  exit 1
fi

# 配置 Nginx 的 default 站点
echo "🛠️ 配置 Nginx default 站点..."

sudo bash -c "cat > /etc/nginx/sites-available/default" <<EOF
server {
    listen 80 default_server;
    server_name _;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2 default_server;
    server_name _;

    ssl_certificate     $cert_path;
    ssl_certificate_key $key_path;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# 创建伪装首页
echo "📄 生成伪装首页 HTML..."
sudo bash -c "cat > /var/www/html/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Welcome</title>
    <style>
        body { font-family: sans-serif; background: #f9f9f9; text-align: center; margin-top: 10%; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Welcome to Nginx Server</h1>
    <p>This server is running normally. Please contact the administrator if you have any questions.</p>
</body>
</html>
HTML

# 设置权限
sudo chown -R www-data:www-data /var/www/html

# 重启 Nginx
echo "🔁 重启 Nginx..."
sudo nginx -t && sudo systemctl restart nginx

echo "✅ 部署完成！请访问 https://你的域名 查看伪装首页"

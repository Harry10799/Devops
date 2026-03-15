sudo apt-get update
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Hello World from Terraform" | sudo tee /var/www/html/index.html


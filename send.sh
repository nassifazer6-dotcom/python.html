#!/bin/bash

# Read HTML content once
HTML_CONTENT=$(< offer.html)

# Check if all.txt exists
if [[ ! -f "all.txt" ]]; then
  echo "❌ File all.txt not found."
  exit 1
fi

# Read and send emails
while IFS= read -r email; do
  echo "📤 Sending to: $email"

  {
    echo "To: $email"
    echo "From: noreply@ups.com"
    echo "Subject: UPS Delivery Waiting"
    echo "MIME-Version: 1.0"
    echo "Content-Type: text/html; charset=UTF-8"
    echo "Content-Transfer-Encoding: 7bit"
    echo ""
    echo "$HTML_CONTENT"
  } | /usr/sbin/sendmail -t &

done < all.txt

# Wait for all background jobs to complete
wait

# Restart Postfix and flush queue
echo "🔁 Restarting Postfix and flushing mail queue..."
sudo service postfix restart
sudo postsuper -r ALL
sudo postqueue -f

echo "📬 All emails sent from all.txt."

# Optional: Delay
sleep 3600

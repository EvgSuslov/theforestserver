

# Server configuration
# USE YOUR OWN PASSWD!

SERVERNAME="github.com/EvgSuslov/theforestserver"
SERVERIP="0.0.0.0"

SERVERPASS="1323"  # USE YOUR OWN PASSWD!
SERVERPASSCONFIRM="1323"# USE YOUR OWN PASSWD!

SERVERPLAYERS=14
DIFFICULTY="Normal" 

if [[ "$SERVERPASS" != "$SERVERPASSCONFIRM" || -z "$SERVERPASS" || -z "$SERVERPASSCONFIRM" ]]; then
  echo -e "\e[31Pass error!\e[0m"
  exit 1
fi

# Запускаем сервер в screen
# Launch the server in screen mode
echo -e "\e[32mЗапуск сервера The Forest...\e[0m"
screen -dmS forest bash -c "cd /home/the-forest/the-forest; \
  xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' wine TheForestDedicatedServer.exe \
  -batchmode -dedicated -nosteamclient \
  -serverip $SERVERIP \
  -serversteamport 8766 \
  -servergameport 27015 \
  -serverqueryport 27016 \
  -servername \"$SERVERNAME\" \
  -serverplayers $SERVERPLAYERS \
  -serverautosaveinterval 15 \
  -difficulty \"$DIFFICULTY\" \
  -slot 3 \
  -serverpassword \"$SERVERPASS\" \
  -enableVAC on > /home/the-forest/server.log 2>&1"

# Проверяем, запущен ли сервер
# Check if the server is running
sleep 5
if screen -list | grep -q "forest"; then
  echo -e "\e[32mСервер The Forest успешно запущен в screen с именем 'forest'.\e[0m"
  echo -e "\e[32mДля просмотра логов используй команду:\e[0m"
  echo "  screen -r forest"
else
  echo -e "\e[31mОшибка: сервер The Forest не запустился. Проверь логи:\e[0m"
  echo "  cat /home/the-forest/server.log"
fi

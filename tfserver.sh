 #!/bin/bash

# Создаем пользователя, если не существует
# Create user if it doesn't exist
id -u the-forest &>/dev/null || useradd -m the-forest
cd /home/the-forest || exit 1

# Добавляем поддержку архитектуры i386
# Adding support for i386 architecture
dpkg --add-architecture i386
echo -e "\e[32mДобавлена поддержка 32-битной архитектуры.\e[0m"

# Устанавливаем зависимости
# Install dependencies
apt update
apt install -y lib32gcc-s1 libc6-i386 libx11-6:i386 libxext6:i386 libxrender1:i386 xvfb wine wget screen curl
echo -e "\e[32mВсе необходимые пакеты установлены.\e[0m"

# Устанавливаем SteamCMD
# Install SteamCMD
if [ ! -d "/home/the-forest/steamcmd" ]; then
  mkdir -p /home/the-forest/steamcmd
  cd /home/the-forest/steamcmd || exit 1
  curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
  chmod +x ./steamcmd.sh
fi
echo -e "\e[32mSteamCMD установлен.\e[0m"

# Скачиваем сервер The Forest
# Download The Forest server
cd /home/the-forest || exit 1
/home/the-forest/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows \
  +force_install_dir /home/the-forest/the-forest \
  +login anonymous +app_update 556450 validate +quit
echo -e "\e[32mСервер The Forest установлен.\e[0m"

# Проверка пути к серверу
# Checking the path to the server
if [ ! -f "/home/the-forest/the-forest/TheForestDedicatedServer.exe" ]; then
  echo -e "\e[31mОшибка: файл сервера The Forest не найден.\e[0m"
  exit 1
fi

# Создаем папки для сохранений и конфигурации
# Create folders for saving and configuration
mkdir -p /home/the-forest/games/data/forest/{saves,config}
echo -e "\e[32mПапки для данных созданы.\e[0m"

# Конфигурация сервера
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

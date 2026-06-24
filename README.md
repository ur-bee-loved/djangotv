# djangotv
Repositório simples cujo objetivo é facilitar a configuração e a utilização das placas raspberry pi conectadas às televisões da empresa.
Todos os arquivos referenciados aqui estarão presentes, também, no corpo do repositório.

Pré-requisitos mínimos:
  HW: Raspberry pi model 2 B
  OS: Raspberry Pi OS Lite
  Acesso à placa via SSH e conexão com a internet, que não explicarei aqui.

Como boas práticas, recomendo que o sistema operacional recém gravado na raspberry pi seja atualizado antes do início do processo. Para fazer isso, executamos:
  sudo apt update && sudo apt upgrade -y

Pacotes requeridos: 
  xinit
  openbox
  chromium
  curl
  xdotool
  scrot 
  Para instalá-los, execute o comando:
    sudo apt install xinit openbox chromium curl xdotool scrot -y

Para melhor utilizarmos os recursos da placa, que tem suas limitações no que tange o processamento, não utilizaremos a GUI do sistema operacional, isso é, configuraremos para que os processos sejam processados diretamente pelo terminal. Podemos fazer isso de algumas maneiras, mas a mais simples é usar o gestor de configurações nativo do sistema:

  sudo raspi-config
  Com esse comando, abrirá-se um menu auxiliar. Deve se ir em 1 "System Options" -> S5 "Boot" -> B1 "Console Text Console"
  O sistema perguntará se queremos reiniciar e, sim, queremos. Isso desabilita o Desktop gerado pela rasp.
  No caso de, após o reboot, ainda assim iniciar-se o desktop deixo aqui algumas medidas auxiliáres para desabilitá-lo:
    Desabilitar o lightdm (responsável por manejar o login na rasp):
      sudo systemctl disable lightdm
      sudo systemctl mask lightdm
    Forçar a configuração padrão do sistema como console sem o menu do próprio sistema:
      sudo systemctl set-default multi-user.target
    Reiniciar os daemons (processos em segundo plano) da placa:
      sudo systemctl daemon-reload

Mesmo que tenhamos, anteriormente, desabilitado o Desktop e o gestor de login, ainda é preciso passar por essa barreira ou o sistema não nos permitirá abrir os processos necessários para prosseguir. Pra isso, criaremos um arquivo de configuração para o _daemon_ gestor de login:
  sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
  sudo nano /etc/systemd/system/getty@tty1.service.d/autologin.conf
    Dentro desse novo arquivo, agora sendo editado, escreva as seguintes informações:
      [Service]
      ExecStart=
      ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM

Ainda utilizando a mesma ferramenta editora de texto, o _nano_, editaremos o perfil de inicialização do sistema, isto é, mandaremos o sistema iniciar a interface gráfica na tela anexada via porta HDMI no assim que iniciar:
  nano ~/.bash_profile
  dentro desse arquivo, escreva:
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    startx
    fi

Para fins de praticidade, não explicarei em detalhes os daemons e ferramentas aqui utilizadas daqui a diante.

Forcemos o xinitrc a utilizar o openbox (que recém instalamos) ao invés do seu fallback _LXDE_
  echo "exec openbox-session" > ~/.xinitrc
  sudo mv /etc/X11/xinit/xinitrc /etc/X11/xinit/xinitrc.bak

Uma vez isso feito, configuremos o próprio openbox:
  mkdir -p ~/.config/openbox
  nano ~/.config/openbox/autostart
  Dentro desse, escreva:
    xset s off
    xset s noblank
    xset -dpms
    /home/pi/djangotv.sh &

  Para tornar o arquivo .sh executável:
    chmod +x ~/.config/openbox/autostart

  Agora, por fim, criemos o script que fará a mágica acontecer. Da mesma forma que anteriormente, cirará-se um arquivo de texto contendo as ordens de serviço e o mesmo deverá ser salvo e tornado em executável:
    nano ~/djangotv.sh
      chmod +x ~/djangotv.sh
  Os conteúdos do script estarão anexados no corpo do repositório.

  Com isso, finalizemos o processo com:
    sudo reboot
  E por fim, na reinicalização, esperamos que a página dos monitores seja devidamente aberta na têvê:

  Algumas notas finais:
    Em caso de dúvida sobre o funcionamento da aplicação nano, tenha em mente que:
    pode-se usar ctrl + shift + c para copiar pedaços de texto
    ctrl + shift + v para colar pedaços de texto
    ctrl x para fechar arquivos
    Caso tenha editado o arquivo e gostaria de salvar, confirme com S ou Y a depender do idioma do sistema e por fim Enter, querendo dizer que quer manter o arquivo       com o mesmo nome.
  

  

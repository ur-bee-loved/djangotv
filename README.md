# djangotv

Repositório simples cujo objetivo é facilitar a configuração e a utilização das placas Raspberry Pi conectadas às televisões da empresa.
Todos os arquivos referenciados aqui estarão presentes, também, no corpo do repositório.

---

## Pré-requisitos

| | |
|---|---|
| **Hardware** | Raspberry Pi Model 2B ou superior |
| **Sistema Operacional** | Raspberry Pi OS Lite (64-bit) |
| **Acesso** | SSH habilitado e conexão com a internet |

---

## 1. Atualizar o sistema

Antes de qualquer coisa, atualize os pacotes do sistema:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 2. Instalar pacotes necessários

```bash
sudo apt install --no-install-recommends \
  xinit openbox chromium curl xdotool scrot -y
```

---

## 3. Desabilitar a interface gráfica

Para melhor aproveitar os recursos limitados da placa, configuramos o sistema para rodar sem desktop. A forma mais simples é pelo gerenciador nativo:

```bash
sudo raspi-config
```

Navegue até: **1 System Options → S5 Boot → B1 Console Text Console**

O sistema perguntará se deseja reiniciar — confirme.

> **Caso o desktop ainda inicie após o reboot**, execute os comandos abaixo para desabilitá-lo manualmente:
>
> ```bash
> sudo systemctl disable lightdm
> sudo systemctl mask lightdm
> sudo systemctl set-default multi-user.target
> sudo systemctl daemon-reload
> ```

---

## 4. Configurar login automático

Crie o arquivo de configuração para login automático no terminal:

```bash
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo nano /etc/systemd/system/getty@tty1.service.d/autologin.conf
```

Cole o seguinte conteúdo:

```ini
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
```

---

## 5. Iniciar X automaticamente no login

```bash
nano ~/.bash_profile
```

Adicione ao final do arquivo:

```bash
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  startx
fi
```

---

## 6. Forçar openbox como gerenciador de janelas

Por padrão, o `startx` usa LXDE como fallback. Substituímos isso pelo openbox, que é muito mais leve:

```bash
echo "exec openbox-session" > ~/.xinitrc
sudo mv /etc/X11/xinit/xinitrc /etc/X11/xinit/xinitrc.bak
```

---

## 7. Configurar o autostart do openbox

```bash
mkdir -p ~/.config/openbox
nano ~/.config/openbox/autostart
```

Cole o seguinte conteúdo:

```bash
xset s off
xset s noblank
xset -dpms
/home/pi/djangotv.sh &
```

Torne o arquivo executável:

```bash
chmod +x ~/.config/openbox/autostart
```

---

## 8. Criar o script principal

```bash
nano ~/djangotv.sh
chmod +x ~/djangotv.sh
```

O conteúdo do script está no arquivo `djangotv.sh` anexado no repositório.

---

## 9. Reiniciar

```bash
sudo reboot
```

Após a reinicialização, a página de monitoramento deverá abrir automaticamente na TV.

---

## Referência rápida — nano

| Ação | Atalho |
|---|---|
| Copiar | `Ctrl + Shift + C` |
| Colar | `Ctrl + Shift + V` |
| Fechar arquivo | `Ctrl + X` |
| Salvar ao fechar | Confirme com `S` ou `Y` + `Enter` |

---

## Resolução de problemas

| Sintoma | Verificação |
|---|---|
| Tela preta após boot | `ps aux \| grep Xorg` — X não iniciou |
| X rodando mas sem Chromium | `cat ~/.xsession-errors` |
| Desktop ainda carrega | `systemctl get-default` deve retornar `multi-user.target`; lightdm deve estar mascarado |
| lxsession assumindo o startx | `~/.xinitrc` deve conter `exec openbox-session` e `/etc/X11/xinit/xinitrc` deve estar renomeado |
| Chromium trava com erro de GPU | Confirme que as flags `--disable-gpu`, `--disable-software-rasterizer`, `--disable-skia-graphite` e `--use-gl=swiftshader` estão presentes no script |
| Modal não é fechado | Recalibre as coordenadas do xdotool com `scrot` — as coordenadas padrão (`916 179`) são para resolução 1920x1080 |
| Erro de autenticação via SSH | `export XAUTHORITY=~/.Xauthority` deve estar no script |

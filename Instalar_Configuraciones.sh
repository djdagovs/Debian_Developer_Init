#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#######################################
# ###     Raúl Caro Pastorino     ### #
## ##                             ## ##
### # https://github.com/fryntiz/ # ###
## ##                             ## ##
# ###       www.fryntiz.es        ### #
#######################################

############################
##   Constantes Colores   ##
############################
amarillo="\033[1;33m"
azul="\033[1;34m"
blanco="\033[1;37m"
cyan="\033[1;36m"
gris="\033[0;37m"
magenta="\033[1;35m"
rojo="\033[1;31m"
verde="\033[1;32m"

#############################
##   Variables Generales   ##
#############################

#Instala el script de OhMyZSH
function ohMyZSH() {
    if [ -f ~/.oh-my-zsh/oh-my-zsh.sh ] #Comprobar si ya esta instalado
    then
        echo -e "$verde Ya esta$rojo OhMyZSH$verde instalado para este usuario, omitiendo paso$gris"
    else
        REINTENTOS=5
        echo -e "$verde Descargando OhMyZSH$gris"
        for (( i=1; i<=$REINTENTOS; i++ ))
        do
            ###TOFIX → Reparar script que sale mal: contraseña PAM y error (no continua por eso)
            rm -R ~/.oh-my-zsh 2>> /dev/null
            curl -L http://install.ohmyz.sh | sh && break || break
        done
    fi
}

function bashit() {
    if [ -f ~/.bash_it/bash_it.sh ] #Comprobar si ya esta instalado
    then
        echo -e "$verde Ya esta$rojo Bash-It$verde instalado para este usuario, omitiendo paso$gris"
        bash ~/.bash_it/install.sh --silent 2>> /dev/null
    else
        REINTENTOS=5

        echo -e "$verde Descargando Bash-It$gris"
        for (( i=1; i<=$REINTENTOS; i++ ))
        do
            rm -R ~/.bash_it 2>> /dev/null
            git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && bash ~/.bash_it/install.sh --silent && break
        done
    fi

    if [ -f ~/.nvm/nvm.sh ] #Comprobar si ya esta instalado
    then
        echo -e "$verde Ya esta$rojo nvm$verde instalado para este usuario, omitiendo paso$gris"
    else
        REINTENTOS=5
        echo -e "$verde Descargando nvm$gris"
        for (( i=1; i<=$REINTENTOS; i++ ))
        do
            rm -R ~/.nvm 2>> /dev/null
            git clone https://github.com/creationix/nvm.git ~/.nvm && ~/.nvm/install.sh && break
        done
    fi

    if [ -f ~/fasd/fasd.1.md ] #Comprobar si ya esta instalado
    then
        echo -e "$verde Ya esta$rojo fasd$verde instalado para este usuario, omitiendo paso$gris"
    else
        REINTENTOS=5

        echo -e "$verde Descargando fasd$gris"
        for (( i=1; i<=$REINTENTOS; i++ ))
        do
            tmp=$pwd
            rm -R -f "~/fasd" 2>> /dev/null
            git clone https://github.com/clvv/fasd ~/fasd && cd ~/fasd && sudo make install && break
            cd $tmp
        done
    fi

    #Instalando dependencias
    echo -e "$verde Instalando dependencias de$rojo Bashit$gris"
    sudo apt install -y rbenv >> /dev/null 2>> /dev/null

    #Habilitar todos los plugins
    #TOFIX → Este paso solo puede hacerse correctamente cuando usamos /bin/bash
    plugins_habilitar="alias-completion aws base battery edit-mode-vi explain extract fasd git gif hg java javascript latex less-pretty-cat node nvm postgres projects python rails ruby sshagent ssh subversion xterm dirs nginx plenv pyenv rbenv"

    if [ -n $BASH ] && [ $BASH = '/bin/bash' ]
    then
        echo -e "$verde Habilitando todos los plugins para$rojo Bashit$gris"

        # Incorpora archivo de bashit
        export BASH_IT="/$HOME/.bash_it"
        export BASH_IT_THEME='powerline-multiline'
        export SCM_CHECK=true
        export SHORT_TERM_LINE=true
        source "$BASH_IT"/bash_it.sh

        for p in $plugins_habilitar
        do
            bash-it enable plugin $p
        done

        #Asegurar que los plugins conflictivos estén deshabilitados:
        echo -e "$verde Deshabilitando plugins no usados en$rojo Bashit$gris"
        bash-it disable plugin chruby chruby-auto z z_autoenv visual-studio-code gh
    else
        echo -e "$verde Para habilitar los$rojo plugins de BASH$verde ejecuta este scripts desde$rojo bash$gris"
    fi
}

#Funcion para configurar VIM con sus temas y complementos
function configurar_vim() {
    echo -e "$verde Configurando VIM"

    function vundle_actualizar_plugins() {
        echo | vim +PluginInstall +qall
    }

    #Instalar Gestor de Plugins Vundle
    function vundle_descargar() {
        echo -e "$verde Descargando Vundle desde Repositorios"
        if [ ! -d ~/.vim/bundle/Vundle.vim ] # Se intenta descargar 10 veces
        then
            for (( i=1; i<=10; i++ ))
            do
                if [ $i -eq 10 ]
                then
                    rm -R ~/.vim/bundle/Vundle.vim 2>> /dev/null
                    break
                fi
                git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
                vundle_actualizar_plugins && break
            done
        else
            echo -e "$verde Vundle ya está instalado$gris"
        fi
    }

    # Instalar Vundle y actualizar Plugins
    vundle_descargar
    vundle_actualizar_plugins

    #Funcion para instalar todos los plugins
    function vim_plugins() {
        plugins_vim=("align closetag powerline youcompleteme xmledit autopep8 python-jedi python-indent utilsinps utl rails snippets fugitive ctrlp tlib tabular sintastic detectindent closetag align syntastic")
        for plugin in $plugins_vim
        do
            echo -e "$verde Activando el plugin  → $rojo $plugin $yellow"
            vim-addon-manager install $plugin >> /dev/null 2>> /dev/null
            vim-addon-manager enable $plugin >> /dev/null 2>> /dev/null
        done
        echo -e "$verde Todos los plugins activados$gris"
    }

    function vim_colores() {
        mkdir -p ~/.vim/colors 2>> /dev/null
        #Creando archivos de colores, por defecto usara "monokai"
        echo -e "$verde Descargando colores para sintaxis$amarillo"

        if [ ! -f "~/.vim/colors/wombat.vim" ]
        then
            wget http://www.vim.org/scripts/download_script.php?src_id=6657 -O ~/.vim/colors/wombat.vim
        fi

        echo -e "$verde Descargando Tema$rojo Monokai$amarillo"
        if [ ! -f "~/.vim/colors/monokai1.vim" ]
        then
            wget https://raw.githubusercontent.com/lsdr/monokai/master/colors/monokai.vim -O ~/.vim/colors/monokai_1.vim
        fi
        echo -e "$verde Se ha concluido la instalacion de temas de colores$gris"
    }

    vim_plugins
    vim_colores
}

#Agregar Archivos de configuración al home
function agregar_conf_home() {
    conf=$(ls -A ./home/)
    echo -e "$verde Preparando para añadir archivos de configuración en el home de usuario$gris"

   for c in $conf
    do
        # Crea backup del directorio o archivo si no tiene una anterior
        if [ -f ./home/$c ]  # Si es un archivo
        then
            if [ ! -f ~/$c.BACKUP ]
            then
                echo -e "$verde Creando Backup del archivo$rojo $c$gris"
                if [ -f ~/$c ]
                then
                    mv ~/$c ~/$c.BACKUP 2>> /dev/null
                else
                    cp -R -f ./home/$c ~/$c.BACKUP 2>> /dev/null
                fi
            fi
            echo -e "$verde Generando configuración del archivo$rojo $c$gris"
            cp -R -f ./home/$c ~/$c 2>> /dev/null
        elif [ -d ./home/$c ]  # Si es un directorio
        then
            if [ ! -d ~/$c.BACKUP ]
            then
                echo -e "$verde Creando Backup del directorio$rojo $c$gris"
                if [ -d ~/$c ]
                then
                    mv ~/$c ~/$c.BACKUP 2>> /dev/null
                else
                    cp -R -f ./home/$c ~/$c.BACKUP 2>> /dev/null
                fi
            fi
            echo -e "$verde Generando configuración del directorio$rojo $c$gris"
            cp -R -f ./home/$c ~/ 2>> /dev/null
        fi
    done
}

#Permisos
function permisos() {
    #sudo rm /bin/atom #Parece que no se crea en las últimas versiones
    echo -e "$verde Estableciendo permisos en el sistema$gris"
}

#Establecer programas por defecto
function programas_default() {
    echo -e "$verde Estableciendo programas por defecto$gris"

    #TERMINAl
    if [ -f /usr/bin/tilix ]
    then
        echo -e "$verde Estableciendo terminal por defecto a$rojo Tilix$gris"
        sudo touch /etc/profile.d/vte.sh 2>> /dev/null
        sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper 2>> /dev/null
    elif [ -f /usr/bin/terminator ]
    then
        echo -e "$verde Estableciendo terminal por defecto a$rojo Terminator$gris"
        sudo update-alternatives --set x-terminal-emulator /usr/bin/terminator
    elif [ -f /usr/bin/sakura ]
    then
        echo -e "$verde Estableciendo terminal por defecto a$rojo Sakura$gris"
        sudo update-alternatives --set x-terminal-emulator /usr/bin/sakura
    else
        echo -e "$verde Estableciendo terminal por defecto a$rojo XTerm$gris"
        sudo update-alternatives --set x-terminal-emulator /usr/bin/xterm
    fi

    #Navegador
    if [ -f /usr/bin/firefox-esr ]
    then
        echo -e "$verde Estableciendo Navegador WEB por defecto a$rojo Firefox-ESR$gris"
        sudo update-alternatives --set x-www-browser /usr/bin/firefox-esr
        sudo update-alternatives --set gnome-www-browser /user/bin/firefox-esr 2>> /dev/null
    elif [ -f /usr/bin/firefox ]
    then
        echo -e "$verde Estableciendo Navegador WEB por defecto a$rojo Firefox$gris"
        sudo update-alternatives --set x-www-browser /usr/bin/firefox
        sudo update-alternatives --set gnome-www-browser /user/bin/firefox 2>> /dev/null
    elif [ -f /usr/bin/chromium ]
    then
        echo -e "$verde Estableciendo Navegador WEB por defecto a$rojo Chromium$gris"
        sudo update-alternatives --set x-www-browser /usr/bin/chromium
        sudo update-alternatives --set gnome-www-browser /user/bin/chromium 2>> /dev/null
    elif [ -f /usr/bin/chrome ]
    then
        echo -e "$verde Estableciendo Navegador WEB por defecto a$rojo chrome$gris"
        sudo update-alternatives --set x-www-browser /usr/bin/chrome
        sudo update-alternatives --set gnome-www-browser /user/bin/chrome 2>> /dev/null
    fi

    #Editor de texto terminal
    if [ -f /usr/bin/vim.gtk3 ]
    then
        echo -e "$verde Estableciendo Editor por defecto a$rojo Vim GTK3$gris"
        sudo update-alternatives --set editor /usr/bin/vim.gtk3
    elif [ -f /usr/bin/vim ]
    then
        echo -e "$verde Estableciendo Editor WEB por defecto a$rojo Vim$gris"
        sudo update-alternatives --set editor /usr/bin/vim
    elif [ -f /bin/nano ]
    then
        echo -e "$verde Estableciendo Editor WEB por defecto a$rojo Nano$gris"
        sudo update-alternatives --set editor /bin/nano
    fi

    #Editor de texto con GUI
    if [ -f /usr/bin/gedit ]
    then
        echo -e "$verde Estableciendo Editor GUI por defecto a$rojo Gedit$gris"
        sudo update-alternatives --set gnome-text-editor /usr/bin/gedit
    elif [ -f /usr/bin/kate ]
    then
        echo -e "$verde Estableciendo Editor GUI por defecto a$rojo Kate$gris"
        sudo update-alternatives --set gnome-text-editor /usr/bin/kate
    elif [ -f /usr/bin/leafpad ]
    then
        echo -e "$verde Estableciendo Editor GUI por defecto a$rojo Leafpad$gris"
        sudo update-alternatives --set gnome-text-editor /usr/bin/leafpad
    fi
}

#Elegir intérprete de comandos
function terminal() {
    while true
    do
        echo -e "$verde Selecciona a continuación el$rojo terminal$verde a usar$gris"
        echo -e "$verde Tenga en cuenta que este script está optimizado para$rojo bash$gris"
        echo -e "$verde 1) bash$gris"
        echo -e "$verde 2) zsh$gris"
        read -p "Introduce el terminal → bash/zsh: " term
        case $term in
            bash | 1)#Establecer bash como terminal
                chsh -s /bin/bash
                # Cambiar enlace por defecto desde sh a bash
                sudo rm /bin/sh
                sudo ln -s /bin/bash /bin/sh
                break;;
            zsh | 2)#Establecer zsh como terminal
                chsh -s /bin/zsh
                # Cambiar enlace por defecto desde sh a zsh
                sudo rm /bin/sh
                sudo ln -s /bin/zsh /bin/sh
                break;;
            *)#Opción errónea
                echo -e "$rojo Opción no válida$gris"
        esac
    done
}

# Configurar editor de gnome, gedit
function configurar_gedit() {
    mkdir -p ~/.local/share/ 2>> /dev/null
    cp -r ./gedit/.local/share/* ~/.local/share/

    mkdir -p ~/.config/gedit/ 2>> /dev/null
    cp -r ./gedit/.config/gedit/* ~/.config/gedit/
}

# Configurar editor de terminal, nano
function configurar_nano() {
    echo -e "$verde Configurando editor nano$gris"

    if [ -d ~/.nano ]
    then
        mv ~/.nano ~/.nanoBACKUP
    fi

    # Clona el repositorio o actualizarlo si ya existe
    if [ -d ~/.nano/.git ]
    then
        # Actualizar Repositorio con git pull
        dir_actual=`echo $PWD`
        cd ~/.nano
        git pull
        cd $dir_actual
    else
        git clone https://github.com/scopatz/nanorc.git ~/.nano
    fi

    # Habilita syntaxis para el usuario
    cat ~/.nano/nanorc >> ~/.nanorc
}

#Crea un archivo hosts muy completo que bloquea bastantes sitios malignos en la web
function configurar_hosts() {
    echo -e "$verde Configurar archivo$rojo /etc/hosts"

    # Crea copia del original para mantenerlo siempre
    if [ ! -f /etc/hosts.BACKUP ]
    then
        sudo mv /etc/hosts /etc/hosts.BACKUP 2>> /dev/null
    fi

    sudo cat /etc/hosts.BACKUP > ./TMP/hosts 2>> /dev/null
    cat ./etc/hosts >> ./TMP/hosts 2>> /dev/null
    sudo cp ./TMP/hosts /etc/hosts 2>> /dev/null
}

# Añadir plantillas
function agregar_plantillas() {
    if [ -d ~/Plantillas ]
    then
        cp -R ./Plantillas/* ~/Plantillas/
    else
        mkdir ~/Plantillas
        cp -R ./Plantillas/* ~/Plantillas/
    fi
}

function tilix_personalizar() {
    # TODO → Comprobar si existe instalado cada tema
    mkdir -p /home/alumno/.config/tilix/schemes/ 2>> /dev/null
    wget -qO $HOME"/.config/tilix/schemes/3024-night.json" https://git.io/v7QVY
    wget -qO $HOME"/.config/tilix/schemes/dimmed-monokai.json" https://git.io/v7QaJ
    wget -qO $HOME"/.config/tilix/schemes/monokai.json" https://git.io/v7Qad
    wget -qO $HOME"/.config/tilix/schemes/monokai-soda.json" https://git.io/v7Qao
    wget -qO $HOME"/.config/tilix/schemes/molokai.json" https://git.io/v7QVE
    wget -qO $HOME"/.config/tilix/schemes/cobalt2.json" https://git.io/v7Qav
    wget -qO $HOME"/.config/tilix/schemes/dracula.json" https://git.io/v7QaT
}

# Instalar Todas las configuraciones
function instalar_configuraciones() {
    bashit
    ohMyZSH
    permisos
    programas_default

    cd $DIR_SCRIPT

    configurar_gedit
    configurar_nano
    agregar_conf_home
    configurar_vim
    configurar_hosts
    agregar_plantillas
    terminal #Pregunta el terminal a usar

    sudo update-command-not-found >> /dev/null 2>> /dev/null
}

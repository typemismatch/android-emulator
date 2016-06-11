# This dockerfile will build an image that can run a full android emulator + the visual emulator over VNC.
# This is maintained and intended to be run in AWS Docker instances with ECS support.
# Based on the work by https://github.com/ConSol/docker-headless-vnc-container

FROM ubuntu:14.04

MAINTAINER Craig Williams "craig@ip80.com"
ENV REFRESHED_AT 2015-12-02

ENV JAVA_VERSION 8u65
ENV JAVA_HOME /usr/lib/jvm/java-$JAVA_VERSION

ENV DEBIAN_FRONTEND noninteractive
ENV DISPLAY :1
ENV NO_VNC_HOME /root/noVNC
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1280x1024
ENV VNC_PW vncpassword

ENV SAKULI_DOWNLOAD_URL https://labs.consol.de/sakuli/install

RUN set -x \
 && : \
 && : add linux-mint dependicies and update packages \
 && apt-key adv --recv-key --keyserver keyserver.ubuntu.com "3EE67F3D0FF405B2" \
 && echo "deb http://packages.linuxmint.com/ rafaela main upstream import" >> /etc/apt/sources.list.d/mint.list \
 && echo "deb http://extra.linuxmint.com/ rafaela main " >> /etc/apt/sources.list.d/mint.list \
 && : \
 && : xvnc / xfce installation \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
	firefox \
	supervisor \
	unzip \
	vim \
	vnc4server \
	wget \
	xfce4 \
 && mkdir -p $NO_VNC_HOME/utils/websockify \
 && wget -qO- https://github.com/kanaka/noVNC/archive/master.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME \
 && wget -qO- https://github.com/kanaka/websockify/archive/v0.7.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify \
 && chmod +x -v /root/noVNC/utils/*.sh \
 && : \
 && : Add Oracle JAVA JRE8 \
 && mkdir -p $JAVA_HOME \
 && wget -qO- $SAKULI_DOWNLOAD_URL/3rd-party/java/jre-$JAVA_VERSION-linux-x64.tar.gz | tar xz --strip 1 -C $JAVA_HOME \
 && update-alternatives --install "/usr/bin/java" "java" "$JAVA_HOME/bin/java" 1 \
 && update-alternatives --install "/usr/bin/javaws" "javaws" "$JAVA_HOME/bin/javaws" 1 \
 && update-alternatives --install "/usr/lib/firefox/browser/plugins/mozilla-javaplugin.so" "mozilla-javaplugin.so" "$JAVA_HOME/lib/amd64/libnpjp2.so" 1 \
 && : \
 && : Install chrome browser \
 && apt-get install -y \
	chromium-browser \
	chromium-browser-l10n \
	chromium-codecs-ffmpeg \
 && ln -s /usr/bin/chromium-browser /usr/bin/google-chrome \
 && echo "alias chromium-browser='/usr/bin/chromium-browser --user-data-dir'" >> /root/.bashrc \
 && : \
 && : Setup specifics for android support - glx drivers etc. \
 && apt-get install -y \
	git \
	lib32gcc1 \
	lib32ncurses5 \
	lib32stdc++6 \
	lib32z1 \
	libc6-i386 \
	libgl1-mesa-dev \
	nano \
 && apt-get clean \
 && : \
 && : Install Android SDK \
 && wget -qO- http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz | tar xz -C /root/ --no-same-permissions \
 && chmod -R a+rX /root/android-sdk-linux \
 && : \
 && : Install Android tools \
 && echo y | /root/android-sdk-linux/tools/android update sdk --filter tools --no-ui --force -a \
 && echo y | /root/android-sdk-linux/tools/android update sdk --filter platform-tools --no-ui --force -a \
 && echo y | /root/android-sdk-linux/tools/android update sdk --filter platform --no-ui --force -a \
 && echo y | /root/android-sdk-linux/tools/android update sdk --filter build-tools-21.0.1 --no-ui -a \
 && echo y | /root/android-sdk-linux/tools/android update sdk --filter sys-img-x86-android-18 --no-ui -a \
 && echo y | /root/android-sdk-linux/tools/android update sdk --filter sys-img-x86-android-19 --no-ui -a \
 && echo y | /root/android-sdk-linux/tools/android update sdk --filter sys-img-x86-android-21 --no-ui -a

ENV ANDROID_HOME /root/android-sdk-linux


# xvnc server porst, if $DISPLAY=:1 port will be 5901
EXPOSE 5901
# novnc web port
EXPOSE 6901

ADD .vnc /root/.vnc
ADD .config /root/.config
ADD Desktop /root/Desktop
ADD scripts /root/scripts
RUN chmod +x /root/.vnc/xstartup /etc/X11/xinit/xinitrc /root/scripts/*.sh /root/Desktop/*.desktop

CMD ["/root/scripts/vnc_startup.sh", "--tail-log"]

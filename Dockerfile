ARG python=false


FROM archlinux:latest AS arch


RUN pacman -Syu --noconfirm \
	&& pacman -S --noconfirm \
	wget \
	curl \
	git \
	base-devel \
	cmake 

RUN git clone https://github.com/neovim/neovim.git --branch stable \
	&& cd neovim \
	&& make CMAKE_BUILD_TYPE=Release \
	&& make install \
	&& cd .. && rm -r neovim

ARG user=dev


# Configure user dev
RUN useradd -m -u 1000 ${user}
USER ${user}
WORKDIR /home/${user}


FROM arch AS python-stage-false


FROM arch AS python-stage-true
USER root
RUN pacman -Syu python python-pip --noconfirm
USER ${user}

FROM python-stage-${python} AS final-stage
RUN echo "HELLO" 

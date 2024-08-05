ARG python=false
ARG install_lazy=true
ARG user=dev
ARG XDG_CONFIG_HOME=/home/${user}/.config

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


FROM arch AS python-stage-false


FROM arch AS python-stage-true
RUN pacman -Syu python python-pip --noconfirm





FROM python-stage-${python} AS create-container-user
ARG user
ARG XDG_CONFIG_HOME
# Configure user dev
RUN useradd -m -u 1000 ${user}
RUN chown -R ${user} /home/${user}
USER ${user}
WORKDIR /home/${user}


FROM python-stage-${python} AS nvim-lazy-false


FROM create-container-user AS nvim-lazy-true
ARG XDG_CONFIG_HOME
ARG user
COPY --chown=${user} ./lazy.lua ${XDG_CONFIG_HOME}/nvim/lua/config/lazy.lua
RUN  echo -e '--LAZY VIM\nrequire("config.lazy")' >> ${XDG_CONFIG_HOME}/nvim/init.lua


FROM nvim-lazy-${install_lazy} AS final-stage
RUN echo "HELLO"



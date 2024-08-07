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
	cmake \
	npm 
RUN git clone https://github.com/neovim/neovim.git --branch stable \
	&& cd neovim \
	&& make CMAKE_BUILD_TYPE=Release \
	&& make install \
	&& cd .. && rm -r neovim



FROM arch AS create-container-user
ARG user
ARG XDG_CONFIG_HOME
# Configure user dev
RUN useradd -m -u 1000 ${user}
RUN chown -R ${user} /home/${user}

FROM create-container-user AS nvim-lazy-false


FROM create-container-user AS nvim-lazy-true
ARG XDG_CONFIG_HOME
ARG user
COPY --chown=${user} ./lazy.lua ${XDG_CONFIG_HOME}/nvim/lua/config/lazy.lua
COPY --chown=${user} ./lua/plugins/ ${XDG_CONFIG_HOME}/nvim/lua/plugins/
RUN echo -e '--LAZY VIM\nrequire("config.lazy")' >> ${XDG_CONFIG_HOME}/nvim/init.lua


FROM nvim-lazy-${install_lazy} AS python-stage-false


FROM nvim-lazy-${install_lazy} AS python-stage-true
RUN pacman -Syu python python-pip --noconfirm && npm install -g pyright
COPY --chown=${user} ./lsp-configs/pyright.lua ${XDG_CONFIG_HOME}/nvim/lua/plugins/lsp/



FROM python-stage-${python} AS final-stage
RUN echo "HELLO"
USER ${user}
WORKDIR /home/${user}

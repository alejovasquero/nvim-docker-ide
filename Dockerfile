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
	npm \
	fzf \
	tmux \
	zsh
RUN git clone https://github.com/neovim/neovim.git --branch stable \
	&& cd neovim \
	&& make CMAKE_BUILD_TYPE=Release \
	&& make install \
	&& cd .. && rm -r neovim



FROM arch AS create-container-user
ARG user
ARG XDG_CONFIG_HOME
# Configure user dev
RUN useradd -m -u 1000 ${user} --shell /bin/zsh # TODO add plugins to zsh and research about its config files
RUN chown -R ${user} /home/${user}

FROM create-container-user AS nvim-lazy-false


FROM create-container-user AS nvim-lazy-true
ARG XDG_CONFIG_HOME
ARG user
COPY --chown=${user} ./lazy.lua ${XDG_CONFIG_HOME}/nvim/lua/config/lazy.lua
COPY --chown=${user} ./lua/plugins/ ${XDG_CONFIG_HOME}/nvim/lua/plugins/
RUN echo -e '--LAZY VIM\nrequire("config.lazy")' >> ${XDG_CONFIG_HOME}/nvim/init.lua

# ZSH CONFIGURATION
COPY --chown=${user} ./zsh /home/${user}/zsh
RUN ln -s /home/${user}/zsh/.zshenv /home/${user}/.zshenv 
RUN ln -s /home/${user}/zsh/.zshrc /home/${user}/.zshrc 

FROM nvim-lazy-${install_lazy} AS python-stage-false


FROM nvim-lazy-${install_lazy} AS python-stage-true
RUN pacman -Syu python python-pip --noconfirm && npm install -g pyright
COPY --chown=${user} ./lsp-configs/pyright.lua ${XDG_CONFIG_HOME}/nvim/lua/plugins/lsp/



FROM python-stage-${python} AS final-stage
RUN echo "HELLO"
USER ${user}
WORKDIR /home/${user}
CMD [ "zsh" ]

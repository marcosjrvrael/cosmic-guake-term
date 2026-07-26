help: ## Mostra esse helper.
	@grep -F -h "##" $(MAKEFILE_LIST) | grep -F -v grep -F | sed -e 's/\\$$//' | sed -e 's/##//'

build: ## Compila o terminal em modo release
	cargo build --release --bin cosmic-guake-term

build-debug: ## Compila o terminal em modo debug
	cargo build --bin cosmic-guake-term

build-applet: ## Compila o applet do painel em modo release
	cargo build --release --bin cosmic-guake-term-applet

run: ## Executa o terminal com logs de debug
	env RUST_LOG=cosmic_guake_term=debug RUST_BACKTRACE=full cargo run --release --bin cosmic-guake-term

run-applet: ## Executa o applet do painel
	env APPLET_LOG_LEVEL=debug cargo run --release --bin cosmic-guake-term-applet

clean: ## Limpa artefatos de build
	cargo clean

install: build build-applet ## Instala binários, .desktop files e ícones
	mkdir -p $(HOME)/.local/bin
	cp target/release/cosmic-guake-term $(HOME)/.local/bin/
	cp target/release/cosmic-guake-term-applet $(HOME)/.local/bin/
	# Desktop files → /usr/local/share/applications (in XDG_DATA_DIRS)
	mkdir -p /usr/local/share/applications 2>/dev/null && \
		cp res/io.github.cosmic-guake-term.GuakeApplet.desktop /usr/local/share/applications/ && \
		cp res/io.github.cosmic-guake-term.desktop /usr/local/share/applications/ || \
		(pkexec mkdir -p /usr/local/share/applications && \
		 pkexec cp $(PWD)/res/io.github.cosmic-guake-term.GuakeApplet.desktop /usr/local/share/applications/ && \
		 pkexec cp $(PWD)/res/io.github.cosmic-guake-term.desktop /usr/local/share/applications/)
	# Icon → user hicolor theme
	for dir in 16x16 24x24 32x32 48x48 64x64 128x128 256x256 symbolic; do \
		src=res/icons/hicolor/$$dir/apps/io.github.cosmic-guake-term*.svg; \
		if ls $$src 2>/dev/null >/dev/null; then \
			mkdir -p $(HOME)/.local/share/icons/hicolor/$$dir/apps; \
			cp $$src $(HOME)/.local/share/icons/hicolor/$$dir/apps/; \
		fi \
	done
	-gtk-update-icon-cache $(HOME)/.local/share/icons/hicolor/ 2>/dev/null
	@echo "Pronto. Adicione o applet no COSMIC Settings → Desktop → Panel → Add Applet"

install-desktop: ## Instala apenas .desktop files e ícones
	# Desktop files → /usr/local/share/applications (in XDG_DATA_DIRS)
	mkdir -p /usr/local/share/applications 2>/dev/null && \
		cp res/io.github.cosmic-guake-term.GuakeApplet.desktop /usr/local/share/applications/ && \
		cp res/io.github.cosmic-guake-term.desktop /usr/local/share/applications/ || \
		(pkexec mkdir -p /usr/local/share/applications && \
		 pkexec cp $(PWD)/res/io.github.cosmic-guake-term.GuakeApplet.desktop /usr/local/share/applications/ && \
		 pkexec cp $(PWD)/res/io.github.cosmic-guake-term.desktop /usr/local/share/applications/)
	# Icon → user hicolor theme
	for dir in 16x16 24x24 32x32 48x48 64x64 128x128 256x256 symbolic; do \
		src=res/icons/hicolor/$$dir/apps/io.github.cosmic-guake-term*.svg; \
		if ls $$src 2>/dev/null >/dev/null; then \
			mkdir -p $(HOME)/.local/share/icons/hicolor/$$dir/apps; \
			cp $$src $(HOME)/.local/share/icons/hicolor/$$dir/apps/; \
		fi \
	done
	-gtk-update-icon-cache $(HOME)/.local/share/icons/hicolor/ 2>/dev/null
	@echo "Pronto"

reset-config: ## Limpa config salvo do COSMIC (use se o terminal não aparecer)
	rm -f $(HOME)/.config/cosmic/io.github.cosmic-guake-term/v1/config.ron
	rm -f $(HOME)/.config/cosmic/io.github.cosmic-guake-term/v1/guake_config
	@echo "Config limpo. Reinicie o app para gerar defaults frescos."

check: ## Executa clippy
	cargo clippy --all-features -- -W clippy::pedantic

test: ## Executa testes (se houver)
	cargo test --release

stop: ## Mata o processo do cosmic-guake-term
	pkill -SIGUSR1 -f "cosmic-guake-term" 2>/dev/null; sleep 0.5; pkill -9 -f "cosmic-guake-term" 2>/dev/null || echo "app not running"

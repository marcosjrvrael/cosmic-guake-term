use cosmic::app::{Core, Task};
use cosmic::iced::window::Id;
use cosmic::surface::action::{app_popup, destroy_popup};
use cosmic::Element;

const APP_ID: &str = "io.github.cosmic-guake-term.GuakeApplet";

fn send_ipc(cmd: &str) {
    let socket_path = std::env::var("XDG_RUNTIME_DIR")
        .map(|d| format!("{d}/cosmic-guake-term.sock"))
        .unwrap_or_else(|_| "/tmp/cosmic-guake-term.sock".to_string());
    log::info!("send_ipc: connecting to {}", socket_path);
    match std::os::unix::net::UnixStream::connect(&socket_path) {
        Ok(mut stream) => {
            use std::io::Write;
            log::info!("send_ipc: connected, sending {}", cmd.trim());
            match stream.write_all(cmd.as_bytes()) {
                Ok(_) => log::info!("send_ipc: sent OK"),
                Err(e) => log::error!("send_ipc: write error: {}", e),
            }
        }
        Err(e) => log::error!("send_ipc: connect error: {}", e),
    }
}

#[derive(Clone, Debug)]
pub enum Message {
    PopupClosed(Id),
    Surface(cosmic::surface::Action<Message>),
    Toggle,
    Settings,
}

pub struct Window {
    core: Core,
    popup: Option<Id>,
}

impl Default for Window {
    fn default() -> Self {
        Self {
            core: Core::default(),
            popup: None,
        }
    }
}

impl cosmic::Application for Window {
    type Executor = cosmic::SingleThreadExecutor;
    type Flags = ();
    type Message = Message;
    const APP_ID: &'static str = APP_ID;

    fn core(&self) -> &Core {
        &self.core
    }

    fn core_mut(&mut self) -> &mut Core {
        &mut self.core
    }

    fn init(core: Core, _flags: Self::Flags) -> (Self, Task<Message>) {
        let window = Window { core, ..Default::default() };
        (window, Task::none())
    }

    fn on_close_requested(&self, id: Id) -> Option<Message> {
        Some(Message::PopupClosed(id))
    }

    fn update(&mut self, message: Message) -> Task<Message> {
        match message {
            Message::PopupClosed(id) => {
                if self.popup.as_ref() == Some(&id) {
                    self.popup = None;
                }
            }
            Message::Surface(a) => {
                return cosmic::task::message(cosmic::Action::Surface(a));
            }
            Message::Toggle => send_ipc("toggle\n"),
            Message::Settings => send_ipc("settings\n"),
        }
        Task::none()
    }

    fn view(&self) -> Element<'_, Message> {
        let have_popup = self.popup.clone();
        let btn = self
            .core
            .applet
            .icon_button("io.github.cosmic-guake-term-symbolic")
            .on_press_with_rectangle(move |offset, bounds| {
                if let Some(id) = have_popup {
                    Message::Surface(destroy_popup(id))
                } else {
                    Message::Surface(app_popup::<Window>(
                        |_| Default::default(),
                        move |state: &mut Window| {
                            let new_id = Id::unique();
                            state.popup = Some(new_id);
                            let mut popup_settings = state.core.applet.get_popup_settings(
                                state.core.main_window_id().unwrap(),
                                new_id,
                                None,
                                None,
                                None,
                            );
                            popup_settings.positioner.anchor_rect = cosmic::iced::Rectangle {
                                x: (bounds.x - offset.x) as i32,
                                y: (bounds.y - offset.y) as i32,
                                width: bounds.width as i32,
                                height: bounds.height as i32,
                            };
                            popup_settings
                        },
                        Some(Box::new(move |state: &Window| {
                            let toggle_btn = cosmic::widget::button::standard("Toggle Terminal")
                                .on_press(Message::Toggle);
                            let settings_btn = cosmic::widget::button::standard("Settings")
                                .on_press(Message::Settings);
                            let content = cosmic::widget::column::with_children(vec![
                                cosmic::widget::text::body("Cosmic Guake Term").into(),
                                toggle_btn.into(),
                                settings_btn.into(),
                            ])
                            .spacing(8)
                            .padding(8);
                            Element::from(
                                state.core.applet.popup_container(content),
                            )
                            .map(cosmic::Action::App)
                        })),
                    ))
                }
            });

        Element::from(self.core.applet.applet_tooltip::<Message>(
            btn,
            "Cosmic Guake Term",
            self.popup.is_some(),
            |a| Message::Surface(a),
            None,
        ))
    }

    fn view_window(&self, _id: Id) -> Element<'_, Message> {
        "unknown".into()
    }

    fn style(&self) -> Option<cosmic::iced::theme::Style> {
        Some(cosmic::applet::style())
    }
}

fn main() -> cosmic::iced::Result {
    env_logger::Builder::from_env(
        env_logger::Env::default()
            .filter_or("APPLET_LOG_LEVEL", "warn")
            .write_style_or("APPLET_LOG_STYLE", "always"),
    )
    .init();
    cosmic::applet::run::<Window>(())
}

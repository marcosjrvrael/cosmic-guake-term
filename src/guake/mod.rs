pub use crate::config::{GuakeConfig, GuakeStartMode};

#[derive(Clone, Debug)]
pub struct GuakeState {
    pub config: GuakeConfig,
    pub visible: bool,
}

impl GuakeState {
    pub fn new(config: GuakeConfig) -> Self {
        let visible = match config.start_mode {
            GuakeStartMode::Normal => true,
            GuakeStartMode::Hidden => false,
        };
        Self { config, visible }
    }

    pub fn toggle(&mut self) {
        self.visible = !self.visible;
    }

    pub fn hide(&mut self) {
        self.visible = false;
    }

    #[allow(dead_code)]
    pub fn show(&mut self) {
        self.visible = true;
    }

    #[allow(dead_code)]
    pub fn width_ratio(&self) -> f64 {
        self.config.width_percent as f64 / 100.0
    }

    #[allow(dead_code)]
    pub fn height_ratio(&self) -> f64 {
        self.config.height_percent as f64 / 100.0
    }
}

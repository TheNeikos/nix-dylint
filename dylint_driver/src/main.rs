#![feature(rustc_private)]

use anyhow::Result;
use std::env;
use std::ffi::OsString;

pub fn main() -> Result<()> {
    env_logger::init();
    let args: Vec<_> = env::args().map(OsString::from).collect();
    dylint_driver::dylint_driver(&args)
}



///
///    Lox REPL in rust - BBHS - CS403
///
///    Rollins Baird
///    Utsav Basu
///    Thomas Hampton
///    Connor Smilth
///

fn main() {
    let mut rl = Editor::<()>::new();
    println!("LOX Interpreter");
    loop {
        let readline = rl.readline("BBHS>> ");
        match readline {
            Ok(line) => {
                match Engine::from_source(&line) {
                    Ok(result) => println!("{}", result),
                    Err(e) => eprintln!("{}", e),
                };

                // cfg_if! {
                //     if #[cfg(any(feature = "jit", feature = "interpreter"))] {
                //         match Engine::from_source(&line) {
                //             Ok(result) => println!("{}", result),
                //             Err(e) => eprintln!("{}", e),
                //         };
                //     }
                //     else if #[cfg(feature = "vm")] {
                //         let byte_code = Engine::from_source(&line);
                //         println!("byte code: {:?}", byte_code);
                //         let mut vm = VM::new(byte_code);
                //         vm.run();
                //         println!("{}", vm.pop_last());
                //     }
                }
            }
            Err(ReadlineError::Interrupted) => {
                println!("CTRL-C");
                break;
            }
            Err(ReadlineError::Eof) => {
                println!("CTRL-D");
                break;
            }
            Err(err) => {
                println!("Error: {:?}", err);
                break;
            }
        }
    }

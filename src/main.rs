use color_eyre::config::HookBuilder;
use color_eyre::eyre;

use crate::build_env::get_build_env;
mod build_env;

#[global_allocator]
static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;

fn foo() -> &'static str {
    "Foo"
}

fn bar() -> &'static str {
    "Bar"
}

fn quz() -> &'static str {
    "Quz"
}

fn i_will_error() -> Result<(), eyre::Report> {
    Err(eyre::Report::msg("I promised you, I'd error!"))
}

fn print_header() {
    const NAME: &str = env!("CARGO_PKG_NAME");
    const VERSION: &str = env!("CARGO_PKG_VERSION");

    let build_env = get_build_env();

    println!(
        "{} v{} - built for {} ({})",
        NAME,
        VERSION,
        build_env.get_target(),
        build_env.get_target_cpu().unwrap_or("base cpu variant"),
    );
}

fn three_branches(parameter1: bool, parameter2: i32) -> bool {
    if parameter1 || parameter2 == 5 {
        println!("TRUE");

        true
    } else {
        println!("FALSE");

        false
    }
}

fn main() -> Result<(), eyre::Report> {
    HookBuilder::default()
        .capture_span_trace_by_default(true)
        .install()?;

    print_header();

    println!("{:?}", three_branches(true, 5));

    println!("{}", foo());
    println!("{}", bar());
    println!("{}", quz());

    i_will_error()
}

#[cfg(test)]
mod tests {
    use super::{bar, foo, quz};
    use crate::three_branches;

    #[test]
    fn assert_foo() {
        assert_eq!(foo(), "Foo");
    }

    #[test]
    fn assert_bar() {
        assert_eq!(bar(), "Bar");
    }

    #[test]
    fn assert_quz() {
        assert_eq!(quz(), "Quz");
    }

    #[test]
    fn assert_combined() {
        assert_eq!(format!("{}-{}-{}", foo(), bar(), quz()), "Foo-Bar-Quz");
    }

    #[test]
    fn three_branches_false_1() {
        let result = three_branches(false, 1);

        assert!(!result);
    }

    #[test]
    fn three_branches_true_1() {
        let result = three_branches(true, 1);

        assert!(result);
    }

    #[test]
    fn three_branches_true_5() {
        let result = three_branches(true, 5);

        assert!(result);
    }

    #[test]
    fn three_branches_false_5() {
        let result = three_branches(false, 5);

        assert!(result);
    }
}

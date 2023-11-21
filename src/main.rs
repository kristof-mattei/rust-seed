fn foo() -> &'static str {
    "Foo"
}

fn bar() -> &'static str {
    "Bar"
}

fn quz() -> &'static str {
    "Quz"
}

fn main() -> Result<(), color_eyre::Report> {
    color_eyre::install()?;
    println!("{}", foo());
    println!("{}", bar());
    println!("{}", quz());

    let héllo = "accent?";
    println!("{}", héllo);

    let foo = "foo";
    let bar = "bar";

    let outer = format!("{foo} {}", bar);
    println!("{}", outer);

    todo!("TODO");
}

fn i_am_dead() {}

#[cfg(test)]
mod tests {
    use super::{bar, foo, quz};

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
}

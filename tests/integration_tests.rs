#[test]
fn assert_world_ok() {
    let cls1 = || true;
    let cls2 = || true;
    assert_eq!(cls1(), cls2());
}

#[test]
fn assert_world_ok2() {
    let cls1 = || false;
    let cls2 = || false;
    assert_eq!(cls1(), cls2());
}

#[test]
fn a_plus_b() {
    assert_eq!(rust_end_to_end_application::add(1, 2), 3);
}

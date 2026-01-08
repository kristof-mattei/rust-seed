use std::error::Error;
use std::fmt;
use std::fs::{File, read_dir};
use std::io::BufReader;
use std::path::Path;

use hashbrown::HashSet;
use serde::de::{DeserializeSeed, IgnoredAny, MapAccess, SeqAccess, Visitor};
use serde_json::de::Deserializer;

fn main() -> Result<(), Box<dyn Error>> {
    let lines = collect_unique_lines(Path::new("src/input"))?;
    println!("{lines:?}");
    Ok(())
}

fn collect_unique_lines(dir: &Path) -> Result<HashSet<String>, Box<dyn Error>> {
    let mut lines = HashSet::new();

    for entry in read_dir(dir)? {
        let entry = entry?;
        if !entry.file_type()?.is_dir() {
            let file = File::open(entry.path())?;
            let reader = BufReader::new(file);
            let mut de = Deserializer::from_reader(reader);
            LinesObjectSeed { lines: &mut lines }.deserialize(&mut de)?;
        }
    }

    Ok(lines)
}

struct LinesObjectSeed<'a> {
    lines: &'a mut HashSet<String>,
}

impl<'de> DeserializeSeed<'de> for LinesObjectSeed<'_> {
    type Value = ();

    fn deserialize<D>(self, deserializer: D) -> Result<(), D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        deserializer.deserialize_map(self)
    }
}

impl<'de> Visitor<'de> for LinesObjectSeed<'_> {
    type Value = ();

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        formatter.write_str("an object containing a `lines` array")
    }

    fn visit_map<M>(self, mut map: M) -> Result<(), M::Error>
    where
        M: MapAccess<'de>,
    {
        while let Some(key) = map.next_key::<String>()? {
            if key == "lines" {
                map.next_value_seed(LinesArraySeed { lines: self.lines })?;
            } else {
                map.next_value::<IgnoredAny>()?;
            }
        }

        Ok(())
    }
}

struct LinesArraySeed<'a> {
    lines: &'a mut HashSet<String>,
}

impl<'de> DeserializeSeed<'de> for LinesArraySeed<'_> {
    type Value = ();

    fn deserialize<D>(self, deserializer: D) -> Result<(), D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        deserializer.deserialize_seq(self)
    }
}

impl<'de> Visitor<'de> for LinesArraySeed<'_> {
    type Value = ();

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        formatter.write_str("an array of lines")
    }

    fn visit_seq<S>(self, mut seq: S) -> Result<(), S::Error>
    where
        S: SeqAccess<'de>,
    {
        while let Some(line) = seq.next_element::<String>()? {
            dbg!(&line);

            self.lines.insert(line);
        }
        Ok(())
    }
}

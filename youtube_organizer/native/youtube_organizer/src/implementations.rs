use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::fs;
use wordcloud_rs::*;

lazy_static! {
    static ref RE_TOKEN: Regex = Regex::new(r"\w+").unwrap();
}

fn tokenize(text: String) -> Vec<(Token, f32)> {
    let mut counts: HashMap<String, usize> = HashMap::new();
    for token in RE_TOKEN.find_iter(&text) {
        *counts.entry(token.as_str().to_string()).or_default() += 1;
    }
    counts
        .into_iter()
        .map(|(k, v)| (Token::Text(k), v as f32))
        .collect()
}

pub fn save_wordcloud_from_file_impl(input_file_path: String, output_path: String) {
    let text = fs::read_to_string(input_file_path).unwrap();
    save_wordcloud_impl(text, output_path);
}

pub fn save_wordcloud_impl(text: String, output_path: String) {
    let mut tokens = tokenize(text);
    // Generate the word-cloud
    let wc = WordCloud::new().generate(tokens);
    // Save it
    wc.save(output_path).unwrap();
}

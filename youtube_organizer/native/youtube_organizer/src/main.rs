use clap::Parser;
mod implementations;
use implementations::save_wordcloud_impl;

#[derive(Parser, Debug)]
struct Args {
    #[arg(short, long)]
    input_file_path: String,
    #[arg(short, long)]
    output_path: String,
}
// assets/sample_text.txt"

fn main() {
    // Prepare the tokens
    let args = Args::parse();

    // tokens.push((Token::Text("💻".to_string()), 20.));
    // Generate the word-cloud
    save_wordcloud_impl(args.input_file_path, args.output_path);
}

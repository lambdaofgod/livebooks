mod implementations;
use implementations::save_wordcloud_impl;

#[rustler::nif]
fn save_wordcloud(input_file_path: String, output_path: String) {
    save_wordcloud_impl(input_file_path, output_path);
}

rustler::init!("Elixir.YTOrg.RustBindings", [save_wordcloud]);

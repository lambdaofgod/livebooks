mod implementations;
use implementations::*;

#[rustler::nif]
fn save_wordcloud_from_file(input_file_path: String, output_path: String) {
    save_wordcloud_from_file_impl(input_file_path, output_path);
}

#[rustler::nif]
fn save_wordcloud(input_file_path: String, output_path: String) {
    save_wordcloud_impl(input_file_path, output_path);
}

rustler::init!(
    "Elixir.YTOrg.RustBindings",
    [save_wordcloud, save_wordcloud_from_file]
);

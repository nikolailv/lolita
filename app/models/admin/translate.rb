class Admin::Translate < Cms::Base
  self.abstract_class = true

  def self.js_translations
    {
      :too_much=>:"javascript.too much",
      :wait_dialog_header=>:"javascript.wait dialog header",
      :confirm=>:"actions.confirm",
      :cancel=>:"actions.cancel",
      :error=>:"simple words.error",
      :error_dialog_text=>:"javascript.error dialog text",
      :saving=>:"javascript.media.saving",
      :changes_saved=>:"javascript.media.changes saved",
      :media_error=>:"media.media_dialog.error",
      :picture_attributes=>:"lolita.media.image_file.dialog.header"
    }
  end
end

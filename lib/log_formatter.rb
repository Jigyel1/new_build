# A sample log_data format from logidze
#
# {
#   "v": 2, // current record version,
#   "h": // list of changes
#     [
#       {
#         "v": 1,  // change number
#         "ts": 1460805759352, // change timestamp in milliseconds
#         "c": {
#             "attr": "new value",  // updated fields with new values
#             "attr2": "new value"
#             }
#         }
#     ]
# }
#
class LogFormatter
  include ActionView::Helpers::TranslationHelper

  TIMESTAMP_KEY = 'updated_at'

  def initialize(log_data)
    @versions = log_data.data['h'].drop(1).reverse
  end

  # case specific log formatting
  #   case 1:
  def call
    ap @versions

    @versions.map do |version|
      fields = version['c']
      field = fields.slice!(TIMESTAMP_KEY) # separate out timestamp & attribute
      key, value = field.first

      whodunnit, dunnittowho = version.dig('m')
                                 &.values_at('responsible_name', 'user_email') #|| [t('logs.admin'), t('logs.user')]

      # byebug

    end
  end

  private

  def users_log

  end

  def project_log

  end

  def formatted_log
    {
      timestamp: version[TIMESTAMP_KEY],
      text: t("logs.#{key}.#{value}", name: whodunnit, email: dunnittowho)
    }
  end
end

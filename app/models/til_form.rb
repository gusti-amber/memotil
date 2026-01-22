class TilForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :path, :string
  attribute :message, :string
  attribute :body, :string
  attribute :repo, :string

  attr_accessor :github_service

  validates :path, presence: true
  validates :repo, presence: true

  validate :validate_path_format
  validate :validate_path_safety
  validate :validate_file_uniqueness

  def initialize(attributes = {}, github_service: nil)
    super(attributes)
    @github_service = github_service # インスタンス変数に直接代入
  end

  private

  def validate_path_format
    return if path.blank?

    errors.add(:path, "は.mdで終わる必要があります") unless path.end_with?(".md")
  end

  def validate_path_safety
    return if path.blank?

    # 禁止文字のチェック
    forbidden_chars = /[:*?"<>|]/
    if forbidden_chars.match?(path)
      errors.add(:path, "に使用できない文字が含まれています")
    end

    # 不正パスパターンのチェック
    invalid_patterns = [
      path.include?(".."),           # 親ディレクトリ参照
      path.include?("//"),           # 連続するスラッシュ
      path.start_with?("/"),         # 絶対パス
      path.include?(".git/"),        # .gitディレクトリ内
      path.start_with?(".git")       # .gitで始まるパス
    ]
    if invalid_patterns.any?
      errors.add(:path, "は不正なパスです")
    end
  end

  def validate_file_uniqueness
    return if path.blank? || repo.blank? || github_service.nil?

    if github_service.file_exists?(repo, path: path)
      errors.add(:path, "はすでに存在しています")
    end
  end
end

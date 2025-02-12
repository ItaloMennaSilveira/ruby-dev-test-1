# frozen_string_literal: true

class Folder < ApplicationRecord
  belongs_to :parent, class_name: 'Folder', optional: true
  has_many :children, class_name: 'Folder', inverse_of: :parent, dependent: :destroy,
                      foreign_key: :parent_id
  has_many :archives, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :parent_id }

  scope :roots, -> { where(parent_id: nil) }

  after_validation :update_path
  after_update :update_children_path
  after_update :update_archives_path

  def update_path
    self.path = '/'
    self.path = "#{parent.path}#{parent.name}/" if parent.present?
  end

  def update_children_path
    children.each do |child|
      child.update_path
      child.save!
    end
  end

  def update_archives_path
    archives.each do |archive|
      archive.update_path
      archive.save!
    end
  end
end

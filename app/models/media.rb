#coding: utf-8

class Media < ActiveRecord::Base
  attr_accessible :title, :text, :kind, :url, :lessons_medias, :wistia_hashed_id
  cattr_accessor :current_status

  TEXT = "Text"

  TYPES = { "Documento" => "Document", 
  					"Slide" => "Slide",
  					"Avaliação" => "Exam", 
  					"Texto" => "Text",
  					"Vídeo" => "Video", 
            "Áudio" => "Audio" }
  VALID_KINDS = ["Document", "Slide", "Text", "Exam", "Video", "Link", "Audio"]
  AVAILABLE_KINDS = ["Video", "Slide", "Audio", "Document", "Text"]

  LIBRARY_TYPES = { "Documento" => "Document", 
                    "Slide" => "Slide",
                    "Vídeo" => "Video", 
                    "Áudio" => "Audio" }

  scope :available, where("text IS NOT NULL OR wistia_hashed_id IS NOT NULL AND wistia_hashed_id <> ''")

  has_many :lessons_medias, dependent: :destroy
  
  has_many :lessons, :through => :lessons_medias
  has_many :courses, :through => :lessons
  has_many :teachers, :through => :courses

  validates :title, length: { minimum: 5, maximum: 100 }
  validates :wistia_hashed_id, presence: true, if: :embed?
  validates :text, length: { minimum: 15, maximum: 5000 }, if: :text?

  def text?
    self.kind == TEXT
  end

  def embed?
    ["Video", "Audio", "Slide", "Document"].include? self.kind
  end

  def text_sample
  	self.text[0..30] if self.text
  end

  def available?
    self.text || self.wistia_hashed_id
  end

  # def destroy
  #   begin
  #     Wistia::Media.find(self.wistia_hashed_id).destroy unless self.wistia_hashed_id.blank?
  #   rescue
  #   end
  #   super
  # end

end

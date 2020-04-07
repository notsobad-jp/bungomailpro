class JuvenileBook < AozoraBook
  default_scope { where(juvenile: true) }
end

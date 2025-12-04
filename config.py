"""Configuration management for the invoice processing system."""
import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    # OpenAI API Key
    openai_api_key: str = ""
    
    # Model Configuration
    openai_model: str = "gpt-4o"  # Updated - gpt-4-vision-preview is deprecated
    
    # API Settings
    api_host: str = "127.0.0.1"
    api_port: int = 8001
    
    # Paths
    invoices_dir: str = "invoices"
    output_dir: str = "output"
    
    # Processing Settings
    max_file_size_mb: int = 10
    timeout_seconds: int = 60
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False  # Accept both OPENAI_API_KEY and openai_api_key


# Global settings instance
settings = Settings()

# Create output directory if it doesn't exist
os.makedirs(settings.output_dir, exist_ok=True)


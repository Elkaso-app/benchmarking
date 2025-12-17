"""Configuration management for the invoice processing system."""
import os
from pydantic_settings import BaseSettings
from pydantic_settings import SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""
    
    # OpenAI API Key
    openai_api_key: str = ""
    
    # Model Configuration
    openai_model: str = "gpt-4o-2024-11-20"  # Latest GPT-4o with improved vision accuracy

    # Anthropic (Claude) Configuration (optional)
    claude_api_key: str = ""
    claude_model: str = "claude-sonnet-4-5-20250929"

    # LLM Provider (optional): "openai" or "anthropic"
    llm_provider: str = "openai"
    
    # Google Document AI Configuration
    google_cloud_project: str = ""
    docai_location: str = "us"
    docai_processor_id: str = ""
    docai_processor_version_id: str = "pretrained-invoice-v2.0-2023-12-06"
    
    # API Settings
    api_host: str = "127.0.0.1"
    api_port: int = 8001
    
    # Paths
    invoices_dir: str = "invoices"
    output_dir: str = "output"
    
    # Processing Settings
    max_file_size_mb: int = 10
    timeout_seconds: int = 60
    
    # Demo Mode - multiplies occurrences by random 13-23 for demo purposes
    demo: bool = False

    # Database Settings (optional, for helper scripts)
    local_db_host: str = ""
    local_db_port: int = 5432
    local_db_name: str = ""
    local_db_user: str = ""
    local_db_password: str = ""
    
    # IMPORTANT: allow extra env vars in .env without crashing
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,  # Accept both OPENAI_API_KEY and openai_api_key
        extra="ignore",
    )


# Global settings instance
settings = Settings()

# Create output directory if it doesn't exist
os.makedirs(settings.output_dir, exist_ok=True)


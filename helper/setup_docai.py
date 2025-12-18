import argparse
import os
from google.api_core.client_options import ClientOptions
from google.cloud import documentai

def create_processor(project_id: str, location: str, display_name: str, processor_type: str = "INVOICE_PROCESSOR"):
    """Creates a new Document AI processor."""
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")
    client = documentai.DocumentProcessorServiceClient(client_options=opts)
    parent = client.common_location_path(project_id, location)

    print(f"Creating {processor_type} processor '{display_name}' in {location}...")
    try:
        processor = client.create_processor(
            parent=parent,
            processor=documentai.Processor(display_name=display_name, type_=processor_type),
        )

        print(f"\n✅ Success!")
        print(f"Processor ID: {processor.name.split('/')[-1]}")
        print(f"Full Name:   {processor.name}")
        print(f"Type:        {processor.type_}")
        return processor
    except Exception as e:
        print(f"❌ Error creating processor: {e}")
        return None

def list_processors(project_id: str, location: str):
    """Lists existing processors in the project/location."""
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")
    client = documentai.DocumentProcessorServiceClient(client_options=opts)
    parent = client.common_location_path(project_id, location)

    print(f"Listing processors in {project_id} ({location})...")
    try:
        processors = client.list_processors(parent=parent)
        
        found = False
        for p in processors:
            found = True
            pid = p.name.split('/')[-1]
            print(f"\n- Display Name: {p.display_name}")
            print(f"  Type:         {p.type_}")
            print(f"  ID:           {pid}")
            print(f"  State:        {p.state.name}")
        
        if not found:
            print("No processors found in this location.")
    except Exception as e:
        print(f"❌ Error listing processors: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Setup Google Document AI Processors")
    parser.add_argument("--project", default="cohesive-amp-436709-n8", help="GCP Project ID")
    parser.add_argument("--location", default="us", help="Location (us or eu)")
    parser.add_argument("--action", choices=["create", "list", "types"], default="list", help="Action to perform")
    parser.add_argument("--name", default="Elkaso-Invoice-Processor", help="Display name for 'create' action")
    parser.add_argument("--type", default="INVOICE_PROCESSOR", help="Processor type for 'create' action")
    
    args = parser.parse_args()
    
    if args.action == "create":
        create_processor(args.project, args.location, args.name, args.type)
    elif args.action == "types":
        fetch_processor_types(args.project, args.location)
    else:
        list_processors(args.project, args.location)

def fetch_processor_types(project_id: str, location: str):
    """Fetches and prints available processor types in the location."""
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")
    client = documentai.DocumentProcessorServiceClient(client_options=opts)
    parent = client.common_location_path(project_id, location)

    print(f"Fetching available processor types in {location}...")
    try:
        response = client.fetch_processor_types(parent=parent)
        print("\nAvailable Processor Types (that you can create):")
        for pt in response.processor_types:
            if pt.allow_creation:
                print(f"- {pt.type_}")
    except Exception as e:
        print(f"❌ Error fetching processor types: {e}")



import requests
import sys
import os
import argparse
from typing import List, Dict, Tuple

# Target architectures to check
TARGET_ARCHITECTURES = {'amd64', 'arm64'}
TIMEOUT_SECONDS = 10

def get_auth_token(repository: str) -> str:
    """Get Docker Hub authentication token."""
    url = "https://auth.docker.io/token"
    params = {
        "service": "registry.docker.io",
        "scope": f"repository:{repository}:pull"
    }
    try:
        response = requests.get(url, params=params, timeout=TIMEOUT_SECONDS)
        response.raise_for_status()
        return response.json()['token']
    except requests.exceptions.RequestException as e:
        print(f"Failed to get auth token: {e}", file=sys.stderr)
        sys.exit(1)

def get_manifest(repository: str, tag: str, token: str) -> Dict:
    """Fetch manifest for specified image."""
    headers = {
        'Accept': 'application/vnd.docker.distribution.manifest.list.v2+json',
        'Authorization': f'Bearer {token}'
    }
    url = f"https://registry-1.docker.io/v2/{repository}/manifests/{tag}"
    try:
        response = requests.get(url, headers=headers, timeout=TIMEOUT_SECONDS)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Failed to get manifest: {e}", file=sys.stderr)
        sys.exit(1)

def check_architectures(manifest: Dict) -> List[str]:
    """Check available architectures in the manifest."""
    if manifest.get('manifests'):
        archs = [m['platform']['architecture'] for m in manifest['manifests']]
        return archs
    else:
        return []

def parse_image_spec(image: str) -> Tuple[str, str]:
    """Parse image specification into repository and tag."""
    if ':' in image:
        repository, tag = image.split(':', 1)
    else:
        repository, tag = image, 'latest'

    if '/' not in repository:
        repository = f'library/{repository}'
    return repository.lower(), tag

def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description='Check Docker image architectures')
    parser.add_argument('image', help='Docker image name (format: name:tag)')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    repository, tag = parse_image_spec(args.image)

    token = get_auth_token(repository)
    manifest = get_manifest(repository, tag, token)
    architectures = check_architectures(manifest)

    if not architectures:
        print(f"No architectures found for {args.image}", file=sys.stderr)
        sys.exit(1)

    available_targets = TARGET_ARCHITECTURES.intersection(architectures)
    missing_targets = TARGET_ARCHITECTURES - set(architectures)

    if not missing_targets:
        print(f"✓ Image {args.image} supports all required architectures")
    else:
        print(f"✗ Image {args.image} is missing architectures: {', '.join(missing_targets)}")
        print(f"Available architectures: {', '.join(architectures)}")

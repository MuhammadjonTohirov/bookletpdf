#!/usr/bin/env python3
"""
Localization Checker for BookletPDF App
Analyzes Swift files for localization keys and validates Localizable.xcstrings completeness
"""

import os
import re
import json
from pathlib import Path
from typing import Set, Dict, List, Tuple
from collections import defaultdict

class LocalizationChecker:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.swift_files = []
        self.localization_keys = set()
        self.localizable_path = None
        self.localizations_data = {}
        self.supported_languages = {'en', 'de', 'fr', 'uz', 'uz-UZ'}
        
    def find_swift_files(self) -> List[Path]:
        """Find all Swift files in the project"""
        swift_files = []
        for root, dirs, files in os.walk(self.project_root):
            # Skip build and derived data directories
            dirs[:] = [d for d in dirs if not d.startswith(('.build', 'DerivedData', '.git'))]
            for file in files:
                if file.endswith('.swift'):
                    swift_files.append(Path(root) / file)
        return swift_files
    
    def extract_localization_keys(self, swift_files: List[Path]) -> Set[str]:
        """Extract all localization keys from Swift files"""
        localization_pattern = r'"(str\.[^"]+)"\.localize'
        keys = set()
        
        print(f"🔍 Analyzing {len(swift_files)} Swift files...")
        
        for file_path in swift_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    matches = re.findall(localization_pattern, content)
                    if matches:
                        print(f"  📄 {file_path.name}: {len(matches)} keys found")
                        for key in matches:
                            keys.add(key)
            except Exception as e:
                print(f"  ❌ Error reading {file_path}: {e}")
        
        return keys
    
    def find_localizable_file(self) -> Path:
        """Find the Localizable.xcstrings file"""
        for root, dirs, files in os.walk(self.project_root):
            for file in files:
                if file == 'Localizable.xcstrings':
                    return Path(root) / file
        raise FileNotFoundError("Localizable.xcstrings not found")
    
    def load_localizations(self, localizable_path: Path) -> Dict:
        """Load and parse the Localizable.xcstrings file"""
        try:
            with open(localizable_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Error loading {localizable_path}: {e}")
            return {}
    
    def analyze_localization_completeness(self) -> Dict:
        """Analyze which keys are missing translations"""
        results = {
            'complete': [],
            'missing_languages': defaultdict(list),
            'missing_keys': [],
            'extra_keys': []
        }
        
        localizable_keys = set()
        strings_data = self.localizations_data.get('strings', {})
        
        # Check each key in Localizable.xcstrings
        for key, data in strings_data.items():
            if key.startswith('str.'):
                localizable_keys.add(key)
                localizations = data.get('localizations', {})
                available_languages = set(localizations.keys())
                
                # Check if all supported languages are present
                missing_langs = self.supported_languages - available_languages
                if not missing_langs:
                    results['complete'].append(key)
                else:
                    for lang in missing_langs:
                        results['missing_languages'][lang].append(key)
        
        # Find keys used in code but missing from Localizable.xcstrings
        results['missing_keys'] = list(self.localization_keys - localizable_keys)
        
        # Find keys in Localizable.xcstrings but not used in code
        results['extra_keys'] = list(localizable_keys - self.localization_keys)
        
        return results
    
    def generate_missing_translations(self, missing_keys: List[str]) -> Dict:
        """Generate translation templates for missing keys"""
        translations = {}
        
        for key in missing_keys:
            # Extract the semantic meaning from the key
            key_name = key.replace('str.', '').replace('_', ' ').title()
            
            translations[key] = {
                "extractionState": "manual",
                "localizations": {
                    "en": {
                        "stringUnit": {
                            "state": "translated",
                            "value": f"TODO: Translate '{key_name}'"
                        }
                    },
                    "de": {
                        "stringUnit": {
                            "state": "translated", 
                            "value": f"TODO: German for '{key_name}'"
                        }
                    },
                    "fr": {
                        "stringUnit": {
                            "state": "translated",
                            "value": f"TODO: French for '{key_name}'"
                        }
                    },
                    "uz": {
                        "stringUnit": {
                            "state": "translated",
                            "value": f"TODO: Uzbek for '{key_name}'"
                        }
                    }
                }
            }
        
        return translations
    
    def print_report(self, analysis: Dict):
        """Print a detailed analysis report"""
        print("\n" + "="*60)
        print("🌍 LOCALIZATION ANALYSIS REPORT")
        print("="*60)
        
        print(f"\n📊 SUMMARY:")
        print(f"  • Swift files analyzed: {len(self.swift_files)}")
        print(f"  • Localization keys found in code: {len(self.localization_keys)}")
        print(f"  • Supported languages: {', '.join(sorted(self.supported_languages))}")
        
        print(f"\n✅ COMPLETE TRANSLATIONS ({len(analysis['complete'])}):")
        if analysis['complete']:
            for key in sorted(analysis['complete'])[:10]:  # Show first 10
                print(f"  • {key}")
            if len(analysis['complete']) > 10:
                print(f"  ... and {len(analysis['complete']) - 10} more")
        else:
            print("  None")
        
        print(f"\n❌ MISSING KEYS IN LOCALIZABLE.XCSTRINGS ({len(analysis['missing_keys'])}):")
        if analysis['missing_keys']:
            for key in sorted(analysis['missing_keys']):
                print(f"  • {key}")
        else:
            print("  None")
        
        print(f"\n⚠️  INCOMPLETE TRANSLATIONS BY LANGUAGE:")
        for lang in sorted(self.supported_languages):
            missing_for_lang = analysis['missing_languages'].get(lang, [])
            print(f"  {lang.upper()}: {len(missing_for_lang)} missing")
            if missing_for_lang:
                for key in sorted(missing_for_lang)[:5]:  # Show first 5
                    print(f"    - {key}")
                if len(missing_for_lang) > 5:
                    print(f"    - ... and {len(missing_for_lang) - 5} more")
        
        print(f"\n🔍 EXTRA KEYS IN LOCALIZABLE.XCSTRINGS ({len(analysis['extra_keys'])}):")
        if analysis['extra_keys']:
            for key in sorted(analysis['extra_keys'])[:10]:  # Show first 10
                print(f"  • {key}")
            if len(analysis['extra_keys']) > 10:
                print(f"  ... and {len(analysis['extra_keys']) - 10} more")
        else:
            print("  None")
    
    def save_missing_keys_template(self, missing_keys: List[str], output_path: str):
        """Save a JSON template for missing keys"""
        if not missing_keys:
            return
        
        template = self.generate_missing_translations(missing_keys)
        
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(template, f, indent=2, ensure_ascii=False)
            print(f"\n💾 Missing keys template saved to: {output_path}")
            print("📝 You can copy these entries to your Localizable.xcstrings file")
        except Exception as e:
            print(f"❌ Error saving template: {e}")
    
    def run_analysis(self) -> Dict:
        """Run the complete localization analysis"""
        print("🚀 Starting Localization Analysis...")
        
        # Find Swift files
        self.swift_files = self.find_swift_files()
        
        # Extract localization keys from Swift files
        self.localization_keys = self.extract_localization_keys(self.swift_files)
        print(f"✅ Found {len(self.localization_keys)} unique localization keys")
        
        # Find and load Localizable.xcstrings
        try:
            self.localizable_path = self.find_localizable_file()
            print(f"📄 Found Localizable.xcstrings at: {self.localizable_path}")
            self.localizations_data = self.load_localizations(self.localizable_path)
        except FileNotFoundError as e:
            print(f"❌ {e}")
            return {}
        
        # Analyze completeness
        analysis = self.analyze_localization_completeness()
        
        # Print report
        self.print_report(analysis)
        
        # Save template for missing keys
        if analysis['missing_keys']:
            template_path = self.project_root / "missing_localizations_template.json"
            self.save_missing_keys_template(analysis['missing_keys'], str(template_path))
        
        return analysis

def main():
    # Set the project root path
    project_root = "/Users/muhammad/Development/Personal/Startups/booklet/bookletpdf"
    
    # Create and run the localization checker
    checker = LocalizationChecker(project_root)
    analysis = checker.run_analysis()
    
    # Additional helpful output
    if analysis:
        total_issues = (
            len(analysis['missing_keys']) + 
            sum(len(keys) for keys in analysis['missing_languages'].values())
        )
        
        print(f"\n🎯 NEXT STEPS:")
        if total_issues == 0:
            print("  🎉 All localization keys are complete!")
        else:
            print(f"  • Fix {len(analysis['missing_keys'])} missing keys")
            print(f"  • Add {sum(len(keys) for keys in analysis['missing_languages'].values())} missing translations")
            print(f"  • Total issues to resolve: {total_issues}")

if __name__ == "__main__":
    main()
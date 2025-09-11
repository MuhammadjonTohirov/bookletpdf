#!/usr/bin/env python3
"""
Auto-Translation Helper for BookletPDF App
Automatically adds missing translations with intelligent defaults
"""

import json
from pathlib import Path
from typing import Dict, List
import re

class AutoTranslator:
    def __init__(self, localizable_path: str):
        self.localizable_path = Path(localizable_path)
        self.translations = {}
        
        # Translation dictionaries for common terms
        self.term_translations = {
            # UI Elements
            'main': {'de': 'Haupt', 'fr': 'Principal', 'uz': 'Asosiy'},
            'settings': {'de': 'Einstellungen', 'fr': 'Réglages', 'uz': 'Sozlamalar'},
            'help': {'de': 'Hilfe', 'fr': 'Aide', 'uz': 'Yordam'},
            'cancel': {'de': 'Abbrechen', 'fr': 'Annuler', 'uz': 'Bekor qilish'},
            'clear': {'de': 'Löschen', 'fr': 'Effacer', 'uz': 'Tozalash'},
            'refresh': {'de': 'Aktualisieren', 'fr': 'Actualiser', 'uz': 'Yangilash'},
            'calculate': {'de': 'Berechnen', 'fr': 'Calculer', 'uz': 'Hisoblash'},
            'convert': {'de': 'Konvertieren', 'fr': 'Convertir', 'uz': 'Aylantirish'},
            'print': {'de': 'Drucken', 'fr': 'Imprimer', 'uz': 'Chop etish'},
            
            # Cache related
            'cache': {'de': 'Cache', 'fr': 'Cache', 'uz': 'Kesh'},
            'size': {'de': 'Größe', 'fr': 'Taille', 'uz': 'Hajm'},
            'current': {'de': 'Aktuell', 'fr': 'Actuel', 'uz': 'Joriy'},
            'cleared': {'de': 'geleert', 'fr': 'vidé', 'uz': 'tozalandi'},
            'successfully': {'de': 'erfolgreich', 'fr': 'avec succès', 'uz': 'muvaffaqiyatli'},
            
            # Document/PDF related
            'document': {'de': 'Dokument', 'fr': 'Document', 'uz': 'Hujjat'},
            'pdf': {'de': 'PDF', 'fr': 'PDF', 'uz': 'PDF'},
            'booklet': {'de': 'Broschüre', 'fr': 'Brochure', 'uz': 'Buklet'},
            'page': {'de': 'Seite', 'fr': 'Page', 'uz': 'Sahifa'},
            'pages': {'de': 'Seiten', 'fr': 'Pages', 'uz': 'Sahifalar'},
            'open': {'de': 'Öffnen', 'fr': 'Ouvrir', 'uz': 'Ochish'},
            'select': {'de': 'Auswählen', 'fr': 'Sélectionner', 'uz': 'Tanlash'},
            
            # Actions and states
            'loading': {'de': 'Laden', 'fr': 'Chargement', 'uz': 'Yuklanmoqda'},
            'calculating': {'de': 'Berechnung...', 'fr': 'Calcul en cours...', 'uz': 'Hisoblanmoqda...'},
            'converting': {'de': 'Konvertierung...', 'fr': 'Conversion en cours...', 'uz': 'Aylantirilmoqda...'},
            'error': {'de': 'Fehler', 'fr': 'Erreur', 'uz': 'Xato'},
            'confirmation': {'de': 'Bestätigung', 'fr': 'Confirmation', 'uz': 'Tasdiqlash'},
            'confirm': {'de': 'Bestätigen', 'fr': 'Confirmer', 'uz': 'Tasdiqlash'},
            
            # Language related
            'language': {'de': 'Sprache', 'fr': 'Langue', 'uz': 'Til'},
            'english': {'de': 'Englisch', 'fr': 'Anglais', 'uz': 'Inglizcha'},
            'french': {'de': 'Französisch', 'fr': 'Français', 'uz': 'Fransuzcha'},
            'german': {'de': 'Deutsch', 'fr': 'Allemand', 'uz': 'Nemischa'},
            'uzbek': {'de': 'Usbekisch', 'fr': 'Ouzbek', 'uz': 'O\'zbekcha'},
            
            # Numbers and formats
            'version': {'de': 'Version', 'fr': 'Version', 'uz': 'Versiya'},
            'format': {'de': 'Format', 'fr': 'Format', 'uz': 'Format'},
            'type': {'de': 'Typ', 'fr': 'Type', 'uz': 'Tur'},
            'support': {'de': 'Support', 'fr': 'Support', 'uz': 'Qo\'llab-quvvatlash'},
        }
        
        # Phrase patterns
        self.phrase_patterns = {
            # Questions
            r'need help': {'de': 'Brauchen Sie Hilfe', 'fr': 'Besoin d\'aide', 'uz': 'Yordam kerakmi'},
            r'are you sure': {'de': 'Sind Sie sicher', 'fr': 'Êtes-vous sûr', 'uz': 'Ishonchingiz komilmi'},
            
            # Instructions
            r'click to': {'de': 'Klicken Sie auf', 'fr': 'Cliquez pour', 'uz': 'Bosish uchun'},
            r'select a': {'de': 'Wählen Sie eine', 'fr': 'Sélectionnez un', 'uz': 'Tanlang'},
            r'choose your': {'de': 'Wählen Sie Ihre', 'fr': 'Choisissez votre', 'uz': 'Tanlang'},
            
            # Status messages
            r'successfully': {'de': 'erfolgreich', 'fr': 'avec succès', 'uz': 'muvaffaqiyatli'},
            r'error calculating': {'de': 'Fehler bei der Berechnung', 'fr': 'Erreur de calcul', 'uz': 'Hisoblashda xato'},
            r'not available': {'de': 'nicht verfügbar', 'fr': 'non disponible', 'uz': 'mavjud emas'},
        }
    
    def load_localizations(self) -> Dict:
        """Load current localizations"""
        try:
            with open(self.localizable_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Error loading localizations: {e}")
            return {}
    
    def intelligent_translate(self, key: str, english_value: str) -> Dict[str, str]:
        """Generate intelligent translations based on patterns and dictionaries"""
        translations = {'de': '', 'fr': '', 'uz': ''}
        
        # Clean the English value
        english_lower = english_value.lower().strip()
        
        # Try direct term translation first
        if english_lower in self.term_translations:
            return self.term_translations[english_lower]
        
        # Try phrase pattern matching
        for pattern, trans in self.phrase_patterns.items():
            if re.search(pattern, english_lower):
                return trans
        
        # Try word-by-word translation for compound phrases
        words = english_lower.replace(':', '').replace('?', '').replace('!', '').split()
        translated_words = {'de': [], 'fr': [], 'uz': []}
        
        for word in words:
            if word in self.term_translations:
                for lang in ['de', 'fr', 'uz']:
                    translated_words[lang].append(self.term_translations[word][lang])
            else:
                # Keep unknown words as-is but capitalized appropriately
                for lang in ['de', 'fr', 'uz']:
                    translated_words[lang].append(word.capitalize())
        
        # Construct translations
        for lang in ['de', 'fr', 'uz']:
            if translated_words[lang]:
                translations[lang] = ' '.join(translated_words[lang])
            else:
                # Fallback: use the key name as a hint
                key_hint = key.replace('str.', '').replace('_', ' ').title()
                translations[lang] = f"[{lang.upper()}] {english_value}"
        
        # Preserve punctuation
        if english_value.endswith(':'):
            for lang in ['de', 'fr', 'uz']:
                if not translations[lang].endswith(':'):
                    translations[lang] += ':'
        elif english_value.endswith('?'):
            for lang in ['de', 'fr', 'uz']:
                if not translations[lang].endswith('?'):
                    translations[lang] += '?'
        elif english_value.endswith('!'):
            for lang in ['de', 'fr', 'uz']:
                if not translations[lang].endswith('!'):
                    translations[lang] += '!'
        elif english_value.endswith('...'):
            for lang in ['de', 'fr', 'uz']:
                if not translations[lang].endswith('...'):
                    translations[lang] += '...'
        
        return translations
    
    def add_missing_translations(self) -> bool:
        """Add missing translations to the localizations data"""
        data = self.load_localizations()
        if not data:
            return False
        
        strings_data = data.get('strings', {})
        updated_count = 0
        
        for key, entry in strings_data.items():
            if not key.startswith('str.'):
                continue
            
            localizations = entry.get('localizations', {})
            
            # Get English value as base for translation
            english_entry = localizations.get('en', {}).get('stringUnit', {})
            english_value = english_entry.get('value', '')
            
            if not english_value:
                continue
            
            # Get intelligent translations
            smart_translations = self.intelligent_translate(key, english_value)
            
            # Add missing translations
            needs_update = False
            for lang in ['de', 'fr', 'uz']:
                if lang not in localizations and lang in smart_translations:
                    localizations[lang] = {
                        "stringUnit": {
                            "state": "translated",
                            "value": smart_translations[lang]
                        }
                    }
                    needs_update = True
            
            # Handle uz-UZ variant (copy from uz)
            if 'uz-UZ' not in localizations and 'uz' in localizations:
                localizations['uz-UZ'] = localizations['uz']
                needs_update = True
            
            if needs_update:
                updated_count += 1
        
        # Save updated data
        try:
            with open(self.localizable_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"✅ Updated {updated_count} keys with missing translations")
            return True
        except Exception as e:
            print(f"❌ Error saving translations: {e}")
            return False
    
    def run(self):
        """Run the auto-translation process"""
        print("🤖 Starting Auto-Translation...")
        
        if self.add_missing_translations():
            print("🎉 Auto-translation completed successfully!")
            print("📝 Review the generated translations and improve them as needed")
        else:
            print("❌ Auto-translation failed")

def main():
    localizable_path = "/Users/muhammad/Development/Personal/Startups/booklet/bookletpdf/bookletPdf/Utils/Resources/Localizable.xcstrings"
    
    translator = AutoTranslator(localizable_path)
    translator.run()

if __name__ == "__main__":
    main()
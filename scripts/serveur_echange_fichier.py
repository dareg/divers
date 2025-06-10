#!/usr/bin/env python3
"""
Serveur web simple pour partager des fichiers en LAN
Usage: python file_server.py [port]
Par défaut le port 8080 est utilisé
"""

import os
import sys
import socket
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime
import shutil
import pathlib

class FileServerHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Gérer les requêtes GET pour afficher la page et télécharger les fichiers"""
        if self.path == '/' or self.path == '/index.html':
            self.send_file_list_page()
        elif self.path.startswith('/download/'):
            self.handle_download()
        else:
            self.send_error(404, "Page non trouvée")
    
    def do_POST(self):
        """Gérer les requêtes POST pour l'upload de fichiers"""
        if self.path == '/upload':
            self.handle_upload()
        else:
            self.send_error(404, "Endpoint non trouvé")
    
    def send_file_list_page(self, message=None, message_type=None):
        """Générer et envoyer la page HTML avec la liste des fichiers"""
        html = self.generate_html_page(message, message_type)
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.send_header('Content-length', len(html.encode('utf-8')))
        self.end_headers()
        self.wfile.write(html.encode('utf-8'))
    
    def generate_html_page(self, message=None, message_type=None):
        """Générer le contenu HTML de la page"""
        files = []
        try:
            for item in os.listdir('.'):
                if os.path.isfile(item):
                    stat = os.stat(item)
                    size = self.format_file_size(stat.st_size)
                    modified = datetime.fromtimestamp(stat.st_mtime).strftime('%d/%m/%Y %H:%M')
                    files.append({
                        'name': item,
                        'size': size,
                        'modified': modified
                    })
        except OSError:
            pass
        
        files.sort(key=lambda x: x['name'].lower())
        
        # Message de statut
        status_html = ""
        if message:
            status_class = "status-success" if message_type == "success" else "status-error"
            status_html = f'<div class="status-message {status_class}">{message}</div>'
        
        # Générer le HTML des fichiers
        files_html = ""
        if files:
            rows = []
            for file in files:
                encoded_name = urllib.parse.quote(file['name'])
                rows.append(f"""
                    <tr>
                        <td><a href="/download/{encoded_name}" class="file-name">🗎 {file['name']}</a></td>
                        <td>{file['size']}</td>
                        <td>{file['modified']}</td>
                    </tr>
                """)
            files_html = """
            <table class="file-table">
                <thead>
                    <tr>
                        <th>📄 Nom du fichier</th>
                        <th>📏 Taille</th>
                        <th>📅 Modifié</th>
                    </tr>
                </thead>
                <tbody>
                    """ + ''.join(rows) + """
                </tbody>
            </table>
            """
        else:
            files_html = '<div class="no-files">Aucun fichier dans ce dossier</div>'
        
        html = f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Partage de fichiers - {socket.gethostname()}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }}
        
        .container {{
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
        }}
        
        .header {{
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 30px;
            text-align: center;
        }}
        
        .header h1 {{
            font-size: 2.2em;
            margin-bottom: 10px;
            font-weight: 300;
        }}
        
        .header p {{
            opacity: 0.9;
            font-size: 1.1em;
        }}
        
        .upload-section {{
            padding: 30px;
            background: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
        }}
        
        .upload-form {{
            display: flex;
            gap: 15px;
            align-items: center;
            justify-content: center;
            flex-wrap: wrap;
        }}
        
        .file-input {{
            padding: 12px;
            border: 2px dashed #667eea;
            border-radius: 8px;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }}
        
        .file-input:hover {{
            border-color: #5a6fd8;
            background: #f8f9ff;
        }}
        
        .upload-btn {{
            background: #28a745;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s ease;
            font-size: 16px;
        }}
        
        .upload-btn:hover {{
            background: #218838;
            transform: translateY(-2px);
        }}
        
        .file-list {{
            padding: 30px;
        }}
        
        .file-list h2 {{
            color: #343a40;
            margin-bottom: 20px;
            font-weight: 400;
        }}
        
        .file-table {{
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }}
        
        .file-table th {{
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #495057;
            border-bottom: 2px solid #dee2e6;
        }}
        
        .file-table td {{
            padding: 15px;
            border-bottom: 1px solid #f8f9fa;
            transition: background 0.2s ease;
        }}
        
        .file-table tr:hover td {{
            background: #f8f9fa;
        }}
        
        .file-name {{
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }}
        
        .file-name:hover {{
            color: #5a6fd8;
            text-decoration: underline;
        }}
        
        .no-files {{
            text-align: center;
            color: #6c757d;
            font-style: italic;
            padding: 40px;
        }}
        
        .status-message {{
            padding: 15px;
            margin: 20px 30px;
            border-radius: 8px;
            font-weight: 500;
        }}
        
        .status-success {{
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }}
        
        .status-error {{
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }}
        
        .back-link {{
            display: inline-block;
            margin: 20px 30px;
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
        }}
        
        .back-link:hover {{
            text-decoration: underline;
        }}
        
        @media (max-width: 768px) {{
            .upload-form {{
                flex-direction: column;
            }}
            
            .file-table {{
                font-size: 14px;
            }}
            
            .file-table th,
            .file-table td {{
                padding: 10px 8px;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📁 Partage de fichiers</h1>
            <p>Serveur: {socket.gethostname()} | Dossier: {pathlib.Path(os.getcwd()).name}</p>
        </div>
        
        <div class="upload-section">
            <form class="upload-form" enctype="multipart/form-data" method="post" action="/upload">
                <input type="file" name="files" class="file-input" multiple required>
                <button type="submit" class="upload-btn">📤 Envoyer les fichiers</button>
            </form>
        </div>
        
        {status_html}
        
        <div class="file-list">
            <h2>📋 Fichiers disponibles ({len(files)})</h2>
            {files_html}
        </div>
    </div>
</body>
</html>"""
        return html
    
    def handle_download(self):
        """Gérer le téléchargement d'un fichier"""
        filename = urllib.parse.unquote(self.path[10:])  # Enlever '/download/'
        
        if not filename or '/' in filename or '\\' in filename or filename.startswith('.'):
            self.send_error(400, "Nom de fichier invalide")
            return
        
        if not os.path.isfile(filename):
            self.send_error(404, "Fichier non trouvé")
            return
        
        try:
            with open(filename, 'rb') as f:
                self.send_response(200)
                self.send_header('Content-Type', 'application/octet-stream')
                self.send_header('Content-Disposition', f'attachment; filename="{filename}"')
                self.send_header('Content-Length', os.path.getsize(filename))
                self.end_headers()
                shutil.copyfileobj(f, self.wfile)
        except OSError as e:
            self.send_error(500, f"Erreur lors de la lecture du fichier: {e}")
    
    def parse_multipart_form_data(self, data, boundary):
        """Parser les données multipart/form-data de manière simple"""
        files = []
        
        # Séparer les parties par le boundary
        boundary_bytes = ('--' + boundary).encode('utf-8')
        parts = data.split(boundary_bytes)
        
        for part in parts[1:-1]:  # Ignorer la première partie vide et la dernière
            if not part.strip():
                continue
                
            # Séparer les headers du contenu
            try:
                header_end = part.find(b'\r\n\r\n')
                if header_end == -1:
                    continue
                    
                headers_data = part[:header_end].decode('utf-8', errors='ignore')
                file_data = part[header_end + 4:]
                
                # Chercher le filename dans Content-Disposition de manière simple
                filename = None
                for line in headers_data.split('\r\n'):
                    if 'Content-Disposition:' in line and 'filename=' in line:
                        # Extraire le nom de fichier entre guillemets
                        start = line.find('filename="')
                        if start != -1:
                            start += 10  # longueur de 'filename="'
                            end = line.find('"', start)
                            if end != -1:
                                filename = line[start:end]
                        break
                
                if filename:
                    # Enlever les derniers \r\n du contenu du fichier
                    if file_data.endswith(b'\r\n'):
                        file_data = file_data[:-2]
                    
                    files.append({
                        'filename': filename,
                        'data': file_data
                    })
                        
            except Exception as e:
                print(f"Erreur lors du parsing d'une partie: {e}")
                continue
        
        return files
    
    def handle_upload(self):
        """Gérer l'upload d'un ou plusieurs fichiers"""
        try:
            content_type = self.headers.get('Content-Type', '')
            if not content_type.startswith('multipart/form-data'):
                self.send_file_list_page("Type de contenu invalide", "error")
                return
            
            # Extraire le boundary
            boundary = None
            for part in content_type.split(';'):
                part = part.strip()
                if part.startswith('boundary='):
                    boundary = part[9:].strip('"')
                    break
            
            if not boundary:
                self.send_file_list_page("Boundary manquant dans le Content-Type", "error")
                return
            
            # Lire les données POST
            content_length = int(self.headers.get('Content-Length', 0))
            if content_length == 0:
                self.send_file_list_page("Aucune donnée reçue", "error")
                return
            
            post_data = self.rfile.read(content_length)
            
            # Parser les données multipart
            files = self.parse_multipart_form_data(post_data, boundary)
            
            uploaded_files = []
            
            for file_info in files:
                filename = self.sanitize_filename(file_info['filename'])
                if filename:
                    # Éviter d'écraser les fichiers existants
                    counter = 0
                    original_filename = filename
                    while os.path.exists(filename):
                        counter += 1
                        name, ext = os.path.splitext(original_filename)
                        filename = f"{name}_{counter}{ext}"
                    
                    with open(filename, 'wb') as f:
                        f.write(file_info['data'])
                    uploaded_files.append(filename)
            
            if uploaded_files:
                message = f"✅ {'Fichier envoyé' if len(uploaded_files) == 1 else 'Fichiers envoyés'}: {', '.join(uploaded_files)}"
                self.send_file_list_page(message, "success")
            else:
                self.send_file_list_page("❌ Aucun fichier valide reçu", "error")
                
        except Exception as e:
            self.send_file_list_page(f"❌ Erreur lors de l'envoie: {e}", "error")
    
    def sanitize_filename(self, filename):
        """Nettoyer le nom de fichier pour éviter les problèmes de sécurité"""
        # Enlever les caractères dangereux
        filename = os.path.basename(filename)
        if filename.startswith('.') or not filename:
            return None
        
        # Remplacer les caractères problématiques
        invalid_chars = '<>:"/\\|?*'
        for char in invalid_chars:
            filename = filename.replace(char, '_')
        
        return filename[:255]  # Limiter la longueur
    
    def format_file_size(self, size):
        """Formatter la taille du fichier de manière lisible"""
        for unit in ['B', 'KiB', 'MiB', 'GiB', 'TiB']:
            if size < 1024.0:
                return f"{size:.1f} {unit}"
            size /= 1024.0
        return f"{size:.1f} PB"
    
    def log_message(self, format, *args):
        """Personnaliser les messages de log"""
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {format % args}")

def get_local_ip():
    """Obtenir l'adresse IP locale"""
    try:
        # Connexion temporaire pour obtenir l'IP locale
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

def main():
    port = 8080
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("Port invalide, utilisation du port 8080 par défaut")
    
    server_address = ('', port)
    httpd = HTTPServer(server_address, FileServerHandler)
    
    local_ip = get_local_ip()
    hostname = socket.gethostname()
    
    print("=" * 60)
    print("SERVEUR DE PARTAGE DE FICHIERS DÉMARRÉ")
    print("=" * 60)
    print(f" Dossier partagé: {os.getcwd()}")
    print(f" Accès local:     http://localhost:{port}")
    print(f" Accès LAN:       http://{local_ip}:{port}")
    print(f" Hostname:        {hostname}")
    print("=" * 60)
    print(" En attente de connexions... (Ctrl+C pour arrêter)")
    print("=" * 60)
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n Arrêt du serveur...")
        httpd.server_close()
        print(" Serveur arrêté proprement")

if __name__ == '__main__':
    main()

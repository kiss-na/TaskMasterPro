
from flask import Flask, send_file
import os

app = Flask(__name__)

@app.route('/download-apk')
def download_apk():
    return send_file('build/app/outputs/flutter-apk/app-release.apk',
                    as_attachment=True,
                    download_name='TaskManager.apk')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

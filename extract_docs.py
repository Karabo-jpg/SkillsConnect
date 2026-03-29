import zipfile
import xml.etree.ElementTree as ET

def get_docx_text(path):
    document = zipfile.ZipFile(path)
    xml_content = document.read('word/document.xml')
    document.close()
    tree = ET.XML(xml_content)
    
    NAMESPACE = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
    TEXT = NAMESPACE + 't'
    
    paragraphs = []
    for paragraph in tree.iter(NAMESPACE + 'p'):
        texts = [node.text for node in paragraph.iter(TEXT) if node.text]
        if texts:
            paragraphs.append("".join(texts))
            
    return "\n".join(paragraphs)

try:
    sample_text = get_docx_text("Group10_Final_Project_Jan_2025.docx")
    with open("sample_report_text.txt", "w", encoding="utf-8") as f:
        f.write(sample_text)
except Exception as e:
    print(f"Error reading sample: {e}")

try:
    part1_text = get_docx_text("Final Project Part 1_ User Research & Design (2).docx")
    with open("part1_report_text.txt", "w", encoding="utf-8") as f:
        f.write(part1_text)
except Exception as e:
    print(f"Error reading part 1: {e}")
print("Extraction complete")

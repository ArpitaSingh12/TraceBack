from __future__ import annotations

from io import BytesIO

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle


def build_product_report(product, batch) -> bytes:
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=letter)
    styles = getSampleStyleSheet()
    story = []

    story.append(Paragraph(f"TraceBack: {product.name}", styles['Title']))
    story.append(Spacer(1, 16))
    story.append(Paragraph(f"Batch: {batch.batch_number}", styles['Heading2']))
    story.append(Paragraph(f"Origin: {product.origin_location}", styles['BodyText']))
    story.append(Paragraph(f"Producer: {product.producer.name}", styles['BodyText']))
    story.append(Paragraph(f"Transparency score: {product.transparency_score}/100", styles['BodyText']))

    data = [["Event type", "Location", "Date", "Organization"]]
    for event in batch.events:
        data.append([event.event_type, event.location, str(event.event_date), event.organization])

    table = Table(data)
    table.setStyle(
        TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1B5E20')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('GRID', (0, 0), (-1, -1), 1, colors.grey),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.whitesmoke, colors.beige]),
        ])
    )
    story.append(Spacer(1, 18))
    story.append(table)

    doc.build(story)
    return buffer.getvalue()

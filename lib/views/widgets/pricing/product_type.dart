/// Backend enum `ProductType`: FULL_CLASS | MENTORSHIP | SUBJECT | MODULE
/// (MODULE == chapter) — exact wire values, confirmed live via
/// `GET /admin/pricing`. Do not rename.
String productTypeLabel(String type) => switch (type) {
      'FULL_CLASS' => 'Full Class',
      'SUBJECT' => 'Subject',
      'MODULE' => 'Chapter',
      'MENTORSHIP' => 'Mentorship',
      _ => type,
    };

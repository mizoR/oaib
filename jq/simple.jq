[
  .id,
  .status,
  "\( .request_counts.completed )/\( .request_counts.total )",
  .request_counts.failed,
  ( .created_at | todate ),
  ( .completed_at | select(type != "null") | todate )
] | @tsv

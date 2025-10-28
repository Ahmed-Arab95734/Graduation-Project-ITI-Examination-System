SELECT 
    qb.Question_ID,
    qc.Question_Choice_ID,
    qc.Choice_Text,
    ROW_NUMBER() OVER (PARTITION BY qb.Question_ID ORDER BY qc.Question_Choice_ID) as ChoiceNumber
FROM [ITIExaminationSystem].[dbo].[Exam_Questions] eq
INNER JOIN [ITIExaminationSystem].[dbo].[Question_Bank] qb 
    ON eq.Question_ID = qb.Question_ID
LEFT JOIN [ITIExaminationSystem].[dbo].[Question_Choice] qc 
    ON qb.Question_ID = qc.Question_ID
WHERE eq.Exam_ID = 1
ORDER BY 
    qb.Question_ID,
    qc.Question_Choice_ID
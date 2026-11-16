CREATE DATABASE hr_analytics;
USE hr_analytics;
# Sql Queries to find insights from the HR employee data

-- Q1. How many employees are in the organization?
SELECT COUNT(*) AS total_employees FROM hr_data;

-- ACTIVE EMPLOYEES
SELECT COUNT(*) AS active_employees
FROM hr_data
WHERE EmploymentStatus = 'Active';

-- EMPLOYEES LEFT
SELECT COUNT(*) AS employees_left
FROM hr_data
WHERE EmploymentStatus IN 
('Voluntarily Terminated', 'Terminated for Cause');

-- Q2. Overall turnover / attrition rate
SELECT 
    COUNT(CASE 
        WHEN EmploymentStatus IN 
        ('Voluntarily Terminated', 'Terminated for Cause') 
        THEN 1 
    END) * 100.0 / COUNT(*) AS turnover_rate
FROM hr_data;

-- Q3. whether employees are mostly leaving voluntarily or being terminated for cause.
SELECT 
    EmploymentStatus,
    COUNT(*) AS employee_count
FROM hr_data
WHERE EmploymentStatus <> 'Active'
GROUP BY EmploymentStatus;

-- Q2. Which departments have the highest employee turnover?
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(
        CASE 
            WHEN EmploymentStatus IN 
            ('Voluntarily Terminated', 'Terminated for Cause')
            THEN 1 ELSE 0
        END
    ) AS employees_left,
    ROUND(
        SUM(
            CASE 
                WHEN EmploymentStatus IN 
                ('Voluntarily Terminated', 'Terminated for Cause')
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate
FROM hr_data
GROUP BY Department
ORDER BY turnover_rate DESC;

-- Q3. Which job roles have the highest turnover?
SELECT
    Position,
    COUNT(*) AS total_employees,
    SUM(
        CASE 
            WHEN EmploymentStatus IN 
            ('Voluntarily Terminated', 'Terminated for Cause')
            THEN 1 ELSE 0
        END
    ) AS employees_left,
    ROUND(
        SUM(
            CASE 
                WHEN EmploymentStatus IN 
                ('Voluntarily Terminated', 'Terminated for Cause')
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate
FROM hr_data
GROUP BY Position
HAVING COUNT(*) >= 3
ORDER BY turnover_rate DESC;

-- Q4. Does lower salary appear to be associated with higher turnover?
SELECT
    CASE
        WHEN Salary < 40000 THEN 'Below 40K'
        WHEN Salary BETWEEN 40000 AND 59999 THEN '40K-60K'
        WHEN Salary BETWEEN 60000 AND 79999 THEN '60K-80K'
        ELSE '80K+'
    END AS salary_range,
    
    COUNT(*) AS total_employees,

    SUM(
        CASE 
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE 
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY salary_range
ORDER BY turnover_rate DESC;

-- Q5. Does lower employee satisfaction correspond to higher turnover?
SELECT
    EmpSatisfaction,
    COUNT(*) AS total_employees,
    
    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY EmpSatisfaction
ORDER BY EmpSatisfaction;

-- Low-satisfaction employees who left
SELECT
    EmpSatisfaction,
    COUNT(*) AS employees_left
FROM hr_data
WHERE EmploymentStatus <> 'Active'
GROUP BY EmpSatisfaction
ORDER BY EmpSatisfaction;

-- Q6. whether performance level is associated with turnover.
SELECT
    PerformanceScore,
    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY PerformanceScore
ORDER BY turnover_rate DESC;


-- Q7. Which recruitment sources provide employees with better retention?
SELECT
    RecruitmentSource,
    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY RecruitmentSource
ORDER BY turnover_rate DESC;

-- Q7. Gender vs turnover
SELECT
    Sex,
    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY Sex
ORDER BY turnover_rate DESC;

-- Q8. Marital status vs turnover
SELECT
    MaritalDesc,
    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY MaritalDesc
ORDER BY turnover_rate DESC;

-- Q9. Create tenure groups
SELECT
    CASE
        WHEN TIMESTAMPDIFF(
            YEAR,
            DateofHire,
            COALESCE(DateofTermination, CURDATE())
        ) < 1 THEN 'Less than 1 year'

        WHEN TIMESTAMPDIFF(
            YEAR,
            DateofHire,
            COALESCE(DateofTermination, CURDATE())
        ) BETWEEN 1 AND 3 THEN '1-3 years'

        WHEN TIMESTAMPDIFF(
            YEAR,
            DateofHire,
            COALESCE(DateofTermination, CURDATE())
        ) BETWEEN 4 AND 6 THEN '4-6 years'

        ELSE '7+ years'
    END AS tenure_group,

    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data

GROUP BY tenure_group

ORDER BY turnover_rate DESC;

-- Q10. Age group analysis
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) < 25 THEN 'Under 25'
        WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN TIMESTAMPDIFF(YEAR, DOB, CURDATE()) BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,

    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY age_group
ORDER BY turnover_rate DESC;

-- Q11. Engagement vs turnover 
SELECT
    CASE
        WHEN EngagementSurvey < 3 THEN 'Low Engagement'
        WHEN EngagementSurvey < 4 THEN 'Medium Engagement'
        ELSE 'High Engagement'
    END AS engagement_level,

    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY engagement_level
ORDER BY turnover_rate DESC;

-- Q12. absence vs turnover
SELECT
    CASE
        WHEN Absences <= 5 THEN 'Low Absence'
        WHEN Absences <= 10 THEN 'Medium Absence'
        ELSE 'High Absence'
    END AS absence_group,

    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data
GROUP BY absence_group
ORDER BY turnover_rate DESC;

-- Q.13 High-Risk Employee Segments
-- department + satisfaction + turnover
SELECT
    Department,
    EmpSatisfaction,
    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data

GROUP BY Department, EmpSatisfaction

HAVING COUNT(*) >= 5

ORDER BY turnover_rate DESC;

-- using department + salary range+ satisfaction 
SELECT
    Department,

    CASE
        WHEN Salary < 40000 THEN 'Below 40K'
        WHEN Salary < 60000 THEN '40K-60K'
        WHEN Salary < 80000 THEN '60K-80K'
        ELSE '80K+'
    END AS salary_range,

    EmpSatisfaction,

    COUNT(*) AS total_employees,

    SUM(
        CASE
            WHEN EmploymentStatus <> 'Active'
            THEN 1 ELSE 0
        END
    ) AS employees_left,

    ROUND(
        SUM(
            CASE
                WHEN EmploymentStatus <> 'Active'
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*), 2
    ) AS turnover_rate

FROM hr_data

GROUP BY
    Department,
    salary_range,
    EmpSatisfaction

HAVING COUNT(*) >= 5

ORDER BY turnover_rate DESC;


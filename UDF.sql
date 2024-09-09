DELIMITER $$
CREATE FUNCTION DateCheck(firstDate DATE, lastDate DATE)
RETURNS BOOL
DETERMINISTIC
BEGIN
	IF YEAR(lastDate) - YEAR(firstDate) < 0 THEN
		RETURN FALSE;
	ELSEIF YEAR(lastDate) - YEAR(firstDate) = 0 THEN
		IF MONTH(lastDate) - MONTH(firstDate) < 0 THEN
			RETURN FALSE;
		ELSEIF MONTH(lastDate) - MONTH(firstDate) = 0 THEN
			IF DAY(lastDate) - DAY(firstDate) <= 0 THEN
				RETURN FALSE;
			END IF;
		END IF;
    END IF;
    RETURN TRUE;
END $$ DELIMITER ;

public interface IDefectFacade {

    /**
    * Return information about fields for defect searching.
    **/
    List<V1FieldData> getFieldsData();

    /**
    * Create defect in the VersionOne and assign it to a case in the Salesforce
    * caseData      - case for assign
    * defectData    - information about new defect
    * Returns id of created defect
    **/
    String createDefectInVersionOne(Case caseData, Defect defectData);

    /**
    * Assign defect in the VersionOne to case in the Salesforce
    * caseData      - case for assignment
    * defectData    - defect to assign
    **/
    void assignDefectToCase(Case caseData, Defect defectData);

    /**
    * Unsaaign a defect from the case. Also removes data from defect in the VersionOne
    * and information about defect from case in the Salesforce
    * caseData - case for removing assigned defect
    **/
    void unassignDefectFromCase(Case caseData);

    /**
    * Get status from the assigned defect and put it to the case
    * caseData      - case for processing
    **/
    void publishStatus(Case caseData);

    /**
    * Get defect from the VersionOne by defect id
    * defectToken   - defect token (for example Defect:1234)
    **/
    Defect getDefectByToken(String defectToken);

    /**
    * Lookup VersionOne defects
    * queryString         - string to look for (see VersionOne REST API)
    * includeClosedItems  - flag determining whether to include closed defects in search result or not
    **/
    List<Defect> searchForDefects(DefectSearchCriteria searchCriteria);

    /**
    * Lookup closed VersionOne defects.
    * dateString        - date since will lookup closed defects.
    * isShowAllCase     - true - show all cases, false only assigned to current user.
    * isClosedCases     - true - show only closed cases, false only open cases.
    * isClosedDefects   - true - show only closed defects, false only open defect.
    **/
    List<DefectWrapper> getCasesWithDefects(Boolean isShowAllCase, Boolean isClosedCases, Boolean isClosedDefects);
}
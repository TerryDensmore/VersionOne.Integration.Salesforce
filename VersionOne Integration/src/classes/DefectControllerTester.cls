@isTest
private class DefectControllerTester {
    private static final String caseSubject = 'TestCase1';
    private static final String caseDescription = 'Description 123';
    private static final String projectName = 'project name';
    private static final String assignedDefectId = DefectFacadeMock.CreatedDefectId;

    static testMethod void mainTest() {
        DefectController controller = getControllerWithoutAssignedDefect();

        Defect defect = controller.getCreatingDefect();
        System.assertEquals(caseSubject, defect.title);
        System.assertEquals(caseDescription, defect.description);

        controller.showForm();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(true, controller.isEditForm);

        controller.refreshWidow();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(false, controller.isEditForm);
    }

    static testMethod void createDefectTest() {
        DefectController controller = getControllerWithoutAssignedDefect();
        controller.createDefect();
        Defect defect = controller.getCreatingDefect();

        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(false, defect.isClosed);
        System.assertEquals(ProjectName, defect.project);
        System.assertEquals(DefectFacadeMock.CreatedDefectId, defect.id);
    }

    static testMethod void createDefectWithExceptionTest() {
        DefectController controller = getControllerWithoutAssignedDefect();
        IDefectFacade facade = controller.defectFacade;
        ((DefectFacadeMock)facade).setCreateDefectInVersionOneException(new IntegrationException('test exception'));
        controller.defectFacade = facade;
        controller.createDefect();
        Defect defect = controller.getCreatingDefect();
        System.assertEquals(true, controller.areThereErrors);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors after failed defect creation.');
    }

    static testMethod void getAssignedDefectTest() {
        DefectController controller = getControllerWithAssignedDefect();

        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(DefectFacadeMock.DefectTitle, defectData.title);
        System.assertEquals(DefectFacadeMock.DefectDescription, defectData.description);
        System.assertEquals(DefectFacadeMock.CreatedDefectId, defectData.id);
    }

    static testMethod void getAssignedDefectWithExceptionTest() {
        DefectController controller = getControllerWithAssignedDefect();
        IDefectFacade facade = controller.defectFacade;
        ((DefectFacadeMock)facade).setGetDefectByIdException(new IntegrationException('test exception'));
        controller.defectFacade = facade;

        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(null, defectData);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of errors after failed defect creation.');
    }

    static testMethod void getAssignedDefectWithoutRequestToV1Test() {
        DefectController controller = getControllerWithAssignedDefect();
        controller.createDefect();
        controller.defectFacade = null;
        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(caseSubject, defectData.title);
        System.assertEquals(caseDescription, defectData.description);
        System.assertEquals(assignedDefectId, defectData.id);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static testMethod void getAssignedDefectWhenDefectIsNotAssignedTest() {
        DefectController controller = getControllerWithoutAssignedDefect();

        Defect defectData = controller.getAssignedDefect();
        System.assertEquals(null, defectData);
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static testMethod void unassignDefectTest() {
        DefectController controller = getControllerWithAssignedDefect();

        controller.unassignDefect();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static testMethod void unassignDefectWithExeptionTest() {
        DefectController controller = getControllerWithAssignedDefect();
        IDefectFacade facade = controller.defectFacade;
        ((DefectFacadeMock)facade).setUnassignDefectFromCaseException(new IntegrationException('test exception'));
        controller.defectFacade = facade;

        controller.unassignDefect();
        System.assertEquals(true, controller.areThereErrors);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static testMethod void publishStatusTest() {
        DefectController controller = getControllerWithAssignedDefect();

        controller.publishStatus();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(0, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static testMethod void publishStatusWithExceptionTest() {
        DefectController controller = getControllerWithAssignedDefect();
        IDefectFacade facade = controller.defectFacade;
        ((DefectFacadeMock)facade).setPublishStatusException(new IntegrationException('test exception'));
        controller.defectFacade = facade;

        controller.publishStatus();
        System.assertEquals(false, controller.areThereErrors);
        System.assertEquals(1, ApexPages.getMessages().size(), 'Incorrect number of warnings after failed defect creation.');
    }

    static testMethod void cancelFormTest() {
        String newTitle = 'new title';
        String newDescription = 'new description';
        DefectController controller = getControllerWithoutAssignedDefect();

        controller.getCreatingDefect().title = newTitle;
        controller.getCreatingDefect().description = newDescription;
        Defect defect = controller.getCreatingDefect();
        controller.isEditForm = true;

        System.assertEquals(newTitle, defect.title, 'Incorrect title');
        System.assertEquals(newDescription, defect.description, 'Incorrect description');
        System.assertEquals(true, controller.isEditForm, 'Incorrect description');

        controller.cancelForm();
        defect = controller.getCreatingDefect();
        System.assertEquals(caseSubject, defect.title, 'Incorrect title');
        System.assertEquals(caseDescription, defect.description, 'Incorrect description');
        System.assertEquals(false, controller.isEditForm, 'Incorrect description');
    }

    private static DefectController getControllerWithoutAssignedDefect() {
        Case caseData = new Case(Subject = caseSubject, Description = caseDescription);
        insert new Case[] {caseData};
        return getController(caseData);
    }

    private static DefectController getControllerWithAssignedDefect() {
        Case caseData = new Case(Subject = caseSubject, Description = caseDescription, V1Association__c = true, V1DefectId__c = assignedDefectId);
        insert new Case[] {caseData};
        return getController(caseData);
    }

    private static DefectController getController(Case caseData) {
        DefectFacadeMock facade = new DefectFacadeMock();
        Settings settingsData = Settings.getTestSettings();
        settingsData.setProjectName(ProjectName);
        DefectController controller = new DefectController(caseData);
        controller.defectFacade = facade;
        controller.settings = settingsData;
        return controller;
    }
}
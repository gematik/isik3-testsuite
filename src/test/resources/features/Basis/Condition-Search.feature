@basis
@mandatory
@Condition-Search
Feature: Testen von Suchparametern gegen condition-read-active (@Condition-Search)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Der Testfall Condition-Read-Active muss zuvor erfolgreich ausgeführt worden sein.
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPaths:
    """
      rest.where(mode = "server").resource.where(type = "Condition" and interaction.where(code = "search-type").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "_id" and type = "token").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "patient" and type = "reference").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "subject" and type = "reference").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "encounter" and type = "reference").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "recorded-date" and type = "date").exists()).exists()
      rest.where(mode = "server").resource.where(type = "Condition" and searchParam.where(name = "related" and type = "reference").exists()).exists()
    """

  Scenario: Suche der Diagnose anhand der ID
    Then Get FHIR resource at "http://fhirserver/Condition/?_id=${data.condition-read-active-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.exists()' with error message 'Es wurden keine Suchergebnisse gefunden'
    And response bundle contains resource with ID "${data.condition-read-active-id}" with error message "Die gesuchte Diagnose ${data.condition-read-active-id} ist nicht im Responsebundle enthalten"
    And FHIR current response body is a valid CORE resource and conforms to profile "https://hl7.org/fhir/StructureDefinition/Bundle"
    And Check if current response of resource "Condition" is valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKDiagnose"

  Scenario: Suche der Diagnose anhand der PatientIn (Suchparameter subject)
    Then Get FHIR resource at "http://fhirserver/Condition/?subject=Patient/${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "${data.patient-read-id}"

  Scenario: Suche der Diagnose anhand der PatientIn (Suchparameter patient)
    Then Get FHIR resource at "http://fhirserver/Condition/?patient=Patient/${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "subject" in all bundle resources references resource with ID "${data.patient-read-id}"


  Scenario: Suche der Diagnose anhand des Kontakts
    Then Get FHIR resource at "http://fhirserver/Condition/?encounter=${data.encounter-read-in-progress-id}" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And element "encounter" in all bundle resources references resource with ID "${data.encounter-read-in-progress-id}"

  Scenario: Suche der Diagnose anhand des Datums der Diagnose mit 'ge' Modifikator
    Then Get FHIR resource at "http://fhirserver/Condition/?recorded-date=ge2021-02-12" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(recordedDate >= @2021-02-12T00:00:00+01:00)' with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'

  Scenario: Suche der Diagnose anhand des Datums der Diagnose mit 'le' Modifikator
    Then Get FHIR resource at "http://fhirserver/Condition/?recorded-date=le2050-01-01" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'entry.resource.count() > 0' with error message 'Es wurden keine Suchergebnisse gefunden'
    And FHIR current response body evaluates the FHIRPath 'entry.resource.all(recordedDate <= @2050-01-01T23:59:59+01:00)' with error message 'Es gibt Suchergebnisse, diese passen allerdings nicht vollständig zu den Suchkriterien.'
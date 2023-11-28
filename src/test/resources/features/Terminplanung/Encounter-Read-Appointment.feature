@terminplanung
@mandatory
@Encounter-Read-Appointment
Feature: Lesen der Ressource Encounter (@Encounter-Read-Appointment)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz sowie die zugewiesene einrichtungsinterne Aufnahmenummer muss in der terminplanung.yaml eingegeben worden sein.

      Testdatensatz (Name: Wert)Legen Sie den folgenden Kontakt mit einer Gesundheitseinrichtung in Ihrem System an:
      Aufnahmenummer: Valide Aufnahmenummer vergeben durch das zu testende System (Bitte ID im terminplanung.yaml eingeben)
      Kontaktebene: Abteilungskontakt
      Status: Durchgeführt
      Typ: Normalstationär
      Patient: Beliebig (Bitte ID im terminplanung.yaml eingeben)
      Referenzierter Termin: Beliebig (Bitte ID im terminplanung.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Encounter" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Encounter anhand der ID
    Then Get FHIR resource at "http://fhirserver/Encounter/${data.encounter-read-appointment-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.encounter-read-appointment-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Encounter"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKTerminKontaktMitGesundheitseinrichtung"
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = '${data.encounter-read-appointment-identifier-system}' and value='${data.encounter-read-appointment-identifier-value}').exists()" with error message 'Der Kontakt enthält nicht die korrekte Aufnahmenummer'
    And TGR current response with attribute "$..status.value" matches "finished"
    And FHIR current response body evaluates the FHIRPath "class.where(code = 'IMP' and system = 'http://terminology.hl7.org/CodeSystem/v3-ActCode').exists()" with error message 'Der Kontakt enthält nicht die korrekte Art'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(code = 'abteilungskontakt' and system = 'http://fhir.de/CodeSystem/Kontaktebene').exists()" with error message 'Der Kontakt enthält nicht den korrekten Typ'
    And FHIR current response body evaluates the FHIRPath "subject.reference.replaceMatches('/_history/.+','').matches('${data.patient-read-id}')" with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "appointment.reference.replaceMatches('/_history/.+','').matches('${data.appointment-read-id}')" with error message 'Der referenzierte Termin entspricht nicht dem Erwartungswert'

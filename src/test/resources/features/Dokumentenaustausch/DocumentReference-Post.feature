@dokumentenaustausch
@mandatory
@DocumentReference-Post
Feature: POST einer DocumentReference (Dokumentenbereitstellung) (@DocumentReference-Post)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die in der DocumentReference hinterlegten Patienten und Encounter mittels Identifier auflösen können. Das  eingebettete Dokument MUSS herausgelöst, separat persistiert und über den Binary-Endpunkt der API abrufbar gemacht werden."
    Given Mit den Vorbedingungen:
      """
       - Der Testfall DocumentReference-Read muss zuvor erfolgreich ausgeführt worden sein.
      """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "create" for resource "DocumentReference"

  Scenario: POST eines DocumentBundles mit bekannten Patienten und Encounter
    Given TGR set default header "Content-Type" to "application/fhir+json"
    When TGR send POST request to "http://fhirserver/DocumentReference" with body "!{file('src/test/resources/features/Dokumentenaustausch/fixtures/DocumentReference-Post-Correct.json')}"
    And TGR find the last request
    Then TGR current response with attribute "$.responseCode" matches "20\d"
#  Caution! The following checks assume, that a representation of the new resource has been returned directly in the response. However, the ISIK spec is unclear at this point:  cf. ongoing clarification in PTDATA-944 and the excerpt from the specification (https://simplifier.net/guide/isik-dokumentenaustausch-v3/markdown-AkteureUndInteraktionen-Interaktion-Dokumentenbereitstellung?version=current):
#  'Die Antwort des Servers erfolgt in Form einer DocumentReference-Ressource (im Erfolgsfall) bzw. einer OperationOutcome-Ressource im Fehlerfall anstelle wie bisher einer Parameters-Ressource.''
    And FHIR current response body is a valid isik3-dokumentenaustausch resource and conforms to profile "https://gematik.de/fhir/isik/v3/Dokumentenaustausch/StructureDefinition/ISiKDokumentenMetadaten"
    And FHIR current response body evaluates the FHIRPath "masterIdentifier.where(system = 'urn:ietf:rfc:3986' and value = 'urn:oid:1.2.840.113556.1.8000.2554.58783.21864.3474.19410.44358.58254.41281.46340').exists()" with error message 'Die versionsspezifische OID des Dokumentes entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "identifier.where(system = 'urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8' and value = '129.6.58.42.11111').exists()" with error message 'Der Identifier entspricht nicht dem Erwartungswert'
    And TGR current response with attribute "$.body.status.content" matches "current"
    And TGR current response with attribute "$.body.docStatus.content" matches "final"
    And TGR current response with attribute "$.body.description.content" matches "Molekularpathologiebefund vom 31.12.21"
    And FHIR current response body evaluates the FHIRPath "type.coding.where(system = 'http://dvmd.de/fhir/CodeSystem/kdl' and code = 'PT130102' and display = 'Molekularpathologiebefund').exists()" with error message 'Der Dokumententyp (KDL) Code entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "type.coding.where(system = 'http://ihe-d.de/CodeSystems/IHEXDStypeCode' and code = 'PATH' and display = 'Pathologiebefundberichte').exists()" with error message 'Der Dokumententyp (XDS) Code entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "${data.documentreference-read-patient-id}" with error message "Der Patientenbezug entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "context.encounter.reference.replaceMatches('/_history/.+','').matches('Encounter/${data.encounter-read-finished-id}$')" with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "author.display.contains('Harold Hippocrates')" with error message 'Die Autorin des Dokumentes entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "securityLabel.coding.where(code = 'N' and system = 'http://terminology.hl7.org/CodeSystem/v3-Confidentiality').exists()" with error message 'Die Vertraulichkeit entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "content.where(attachment.where(contentType = 'application/pdf' and language = 'de' and url.exists() and creation.toString().contains('2022-12-31T23:50:50-05:00')).exists() and format.where(code = 'urn:ihe:iti:xds:2017:mimeTypeSufficient' and system = 'http://ihe.net/fhir/ihe.formatcode.fhir/CodeSystem/formatcode').exists()).exists()" with error message 'Der Anhang entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "context.where(facilityType.coding.where(code = 'KHS' and system = 'http://ihe-d.de/CodeSystems/PatientBezogenenGesundheitsversorgung').exists() and practiceSetting.where(coding.where(code = 'ALLG' and system = 'http://ihe-d.de/CodeSystems/AerztlicheFachrichtungen').exists()).exists()).exists()" with error message 'Der Kontext entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "category.coding.where(code = 'BEF' and system = 'http://ihe-d.de/CodeSystems/IHEXDSclassCode' and display = 'Befundbericht').exists()" with error message 'Die Dokumentklasse entspricht nicht dem Erwartungswert'

#  Scenario Outline: POST eines inkorrekten DocumentBundles
#    Given TGR set default header "Content-Type" to "application/fhir+json"
#    When TGR send POST request to "http://fhirserver/" with body "!{file('src/test/resources/features/Dokumentenaustausch/fixtures/<inputFile>')}"
#    And TGR find the last request
#    Then TGR current response with attribute "$.responseCode" matches "<responseCode>"
#    And FHIR current response body evaluates the FHIRPath "issue.where(severity = 'error' or 'fatal').count() >= 1" with error message 'Das OperationOutcome enthält nicht den/die geforderten Issues'
#
#    Examples:
#      |  inputFile                                                 | responseCode |
#      |  DocumentReference-Post-UnknownPatient.json     |    422       |
#      |  DocumentReference-Post-UnknownEncounter.json   |    422       |
#      |  DocumentReference-Post-MissingAttachmentData.json        |    4\d\d     |